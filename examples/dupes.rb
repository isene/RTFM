# @name: Dupes
# @description: Find duplicate files by content hash in current directory
# @key: F7

require 'digest'
require 'shellwords'

KEYMAP['F7'] = :find_dupes

PLUGIN_HELP['Dupes'] = <<~HELP
  Find duplicate files by content hash.

  Press F7 to scan the current directory for files
  that share identical content.

  #{"Scanning:".b}
    Files are first grouped by size, then only
    same-size files are hashed (SHA256) to confirm
    duplicates. Press 'r' at the start prompt to
    scan recursively.

  #{"Navigation:".b}
    j/k         Move between duplicate groups
    PgDn/PgUp   Jump 10 groups
    LEFT/RIGHT  Move between files in a group
    t           Tag file to KEEP
    d           Delete all untagged files in group
    q/ESC       Close

  #{"Deletion:".b}
    If trash mode is enabled, deleted files are
    moved to the trash and can be undone. Otherwise
    files are permanently removed.

  #{"Display:".b}
    Groups are sorted by wasted space (largest
    first). Each group shows a partial hash, file
    size, and the list of duplicate paths.
HELP

def find_dupes
  clear_image

  @pB.say("Scan duplicates: ENTER=current dir, r=recursive, q=cancel")
  chr = getchr
  return if chr == 'q' || chr == 'ESC'
  recursive = (chr == 'r')

  dupes_progress("Collecting files#{recursive ? ' recursively' : ''}... (any key to cancel)")

  # Collect files with cancellation support
  all_files = []
  cancelled = false
  if recursive
    dirs = [Dir.pwd]
    while dirs.any?
      break if cancelled
      dir = dirs.shift
      begin
        Dir.foreach(dir) do |entry|
          next if entry == '.' || entry == '..'
          path = File.join(dir, entry)
          if File.directory?(path) && !File.symlink?(path)
            dirs << path
          elsif File.file?(path) && !File.symlink?(path)
            all_files << path
          end
          if all_files.size % 200 == 0
            dupes_progress("Collecting: #{all_files.size} files... (any key to cancel)")
            if dupes_cancelled?
              cancelled = true
              break
            end
          end
        end
      rescue Errno::EACCES, Errno::ENOENT
        next
      end
    end
  else
    Dir.foreach(Dir.pwd) do |entry|
      next if entry == '.' || entry == '..'
      path = File.join(Dir.pwd, entry)
      all_files << path if File.file?(path) && !File.symlink?(path)
    end
  end

  if cancelled && all_files.empty?
    @pB.say("Scan cancelled.")
    return
  end

  if all_files.empty?
    @pB.say("No files found.")
    return
  end

  # Pass 1: group by size (with cancellation)
  by_size = {}
  all_files.each_with_index do |f, i|
    if i % 500 == 0
      dupes_progress("Pass 1/2: sizing #{i}/#{all_files.size}... (any key to cancel)")
      if dupes_cancelled?
        cancelled = true
        break
      end
    end
    begin
      sz = File.size(f)
      (by_size[sz] ||= []) << f
    rescue
      next
    end
  end
  by_size.delete(0)
  candidates = by_size.values.select { |g| g.size > 1 }

  if candidates.empty?
    @pB.say(cancelled ? "Scan cancelled. No duplicates in partial results." : "No duplicate candidates (all files have unique sizes).")
    return
  end

  # Pass 2: hash same-size files (with cancellation)
  total = candidates.sum(&:size)
  done = 0
  by_hash = {}
  candidates.each do |group|
    break if cancelled
    group.each do |f|
      done += 1
      if done % 10 == 1 || done == total
        dupes_progress("Pass 2/2: hashing #{done}/#{total}... (any key to cancel)")
        if IO.select([$stdin], nil, nil, 0)
          $stdin.read_nonblock(16) rescue nil
          cancelled = true
          break
        end
      end
      begin
        digest = Digest::SHA256.new
        File.open(f, 'rb') do |io|
          buf = String.new(capacity: 65536)
          while io.read(65536, buf)
            digest.update(buf)
          end
        end
        hex = digest.hexdigest
        (by_hash[hex] ||= []) << f
      rescue
        next
      end
    end
  end

  if cancelled
    @pB.say("Scan cancelled. Showing partial results...")
  end

  dupes = by_hash.values.select { |g| g.size > 1 }

  if dupes.empty?
    @pB.say("No duplicates found (same-size files had different content).")
    return
  end

  # Sort by wasted space descending
  dupes.sort_by! { |g| -(File.size(g[0]) * (g.size - 1)) rescue 0 }

  # Precompute group metadata
  group_meta = dupes.map do |group|
    sz = File.size(group[0]) rescue 0
    { size: sz, waste: sz * (group.size - 1) }
  end
  wasted_total = group_meta.sum { |m| m[:waste] }

  group_idx = 0
  file_idx = 0
  kept = {} # group_idx => Set of file indices to keep

  loop do
    group = dupes[group_idx]
    meta = group_meta[group_idx]
    kept[group_idx] ||= []

    lines = []
    lines << "j/k:group  LEFT/RIGHT:file  t:keep  d:delete untagged  q:close".fg(240)
    lines << "Duplicate Files".b.fg(254) + "  (#{group_idx + 1}/#{dupes.size} groups, #{format_bytes(wasted_total)} wasted)".fg(240)
    lines << ""

    header = "#{format_bytes(meta[:size])} x#{group.size} (#{format_bytes(meta[:waste])} wasted)"
    lines << header.b.fg(112)

    group.each_with_index do |f, fi|
      rel = f.start_with?(Dir.pwd + '/') ? f.sub(Dir.pwd + '/', '') : f
      is_kept = kept[group_idx].include?(fi)
      marker = is_kept ? " KEEP ".bg(22).fg(255) : "      "
      label = "#{marker} #{rel}"
      label = fi == file_idx ? label.u.fg(254) : label.fg(250)
      lines << label
    end

    lines << ""
    # Show neighboring groups for context (compact, no file listing)
    context_start = [group_idx - 2, 0].max
    context_end = [group_idx + 5, dupes.size - 1].min
    (context_start..context_end).each do |gi|
      next if gi == group_idx
      g = dupes[gi]
      m = group_meta[gi]
      lines << "  [#{gi + 1}] #{format_bytes(m[:size])} x#{g.size} (#{format_bytes(m[:waste])} wasted)".fg(240)
    end

    @pR.update = true
    @pR.say(lines.join("\n"))

    chr = getchr
    case chr
    when 'q', 'ESC'
      break
    when 'j', 'DOWN'
      group_idx = (group_idx + 1) % dupes.size
      file_idx = 0
    when 'k', 'UP'
      group_idx = (group_idx - 1) % dupes.size
      file_idx = 0
    when 'PgDOWN'
      group_idx = [group_idx + 10, dupes.size - 1].min
      file_idx = 0
    when 'PgUP'
      group_idx = [group_idx - 10, 0].max
      file_idx = 0
    when 'RIGHT', 'l', 'ENTER'
      file_idx = (file_idx + 1) % group.size
    when 'LEFT', 'h'
      file_idx = (file_idx - 1) % group.size
    when 't'
      # Toggle keep tag on current file
      if kept[group_idx].include?(file_idx)
        kept[group_idx].delete(file_idx)
      else
        kept[group_idx] << file_idx
      end
      file_idx = (file_idx + 1) % group.size if file_idx < group.size - 1
    when 'd'
      # Delete all files NOT tagged as keep
      to_keep = kept[group_idx] || []
      if to_keep.empty?
        @pB.say("Tag at least one file to keep first (press t).")
        next
      end
      to_delete = group.each_index.reject { |i| to_keep.include?(i) }
      if to_delete.empty?
        @pB.say("All files tagged as keep, nothing to delete.")
        next
      end
      names = to_delete.map { |i| File.basename(group[i]) }
      @pB.say("Delete #{to_delete.size} files? (y/n)")
      if getchr == 'y'
        deleted = 0
        to_delete.sort.reverse.each do |fi|
          path = group[fi]
          begin
            if @trash
              timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
              trash_name = "#{timestamp}_#{File.basename(path)}_#{rand(1000..9999)}"
              trash_path = File.join(TRASH_DIR, trash_name)
              command("mv -f #{Shellwords.escape(path)} #{Shellwords.escape(trash_path)}")
              add_undo_operation({ type: 'delete', trash: true, paths: [{ path: path, trash_name: trash_name }], timestamp: Time.now })
            else
              command("rm -rf #{Shellwords.escape(path)}")
            end
            deleted += 1
          rescue
          end
        end
        # Remove deleted files from group (reverse order to preserve indices)
        to_delete.sort.reverse.each { |fi| group.delete_at(fi) }
        kept.delete(group_idx)
        file_idx = 0
        # Update metadata
        meta[:waste] = (meta[:size] * (group.size - 1)) rescue 0
        group_meta[group_idx] = meta
        wasted_total = group_meta.sum { |m| m[:waste] }
        # Remove group if only one file remains
        if group.size <= 1
          dupes.delete_at(group_idx)
          group_meta.delete_at(group_idx)
          # Shift kept indices
          new_kept = {}
          kept.each { |k, v| new_kept[k > group_idx ? k - 1 : k] = v if k != group_idx }
          kept = new_kept
          if dupes.empty?
            @pB.say("All duplicates resolved! Freed #{format_bytes(wasted_total)}.")
            break
          end
          group_idx = [group_idx, dupes.size - 1].min
          wasted_total = group_meta.sum { |m| m[:waste] }
        end
        @pB.say("Deleted #{deleted} files.")
      end
    end
  end

  @pR.update = true
  refresh
  render
end

def dupes_progress(msg)
  @pB.update = true
  @pB.say(msg)
  @pB.refresh
end

def dupes_cancelled?
  begin
    $stdin.read_nonblock(1)
    $stdin.read_nonblock(16) rescue nil
    true
  rescue IO::WaitReadable, EOFError
    false
  end
end

def format_bytes(bytes)
  if bytes >= 1073741824
    "%.1f GB" % (bytes / 1073741824.0)
  elsif bytes >= 1048576
    "%.1f MB" % (bytes / 1048576.0)
  elsif bytes >= 1024
    "%.1f KB" % (bytes / 1024.0)
  else
    "#{bytes} B"
  end
end
