# @name: Disk Usage
# @description: Interactive disk usage analyzer for current directory
# @key: S (extends system info)

KEYMAP['S'] = :diskusage_menu

PLUGIN_HELP['Disk Usage'] = <<~HELP
  Interactive disk usage analyzer for the current directory.

  Press S to open the system/disk usage menu.

  #{"Menu:".bd}
    s   Show system info (original S behavior)
    d   Open disk usage analyzer

  #{"Disk Usage Analyzer:".bd}
    j/k       Navigate up/down
    ENTER     Drill into selected directory
    LEFT/h    Go up to parent directory
    q/ESC     Close analyzer

  Scanning can be cancelled with ESC. The analyzer
  shows all files and directories sorted by size
  (largest first), with visual bars and human-readable
  sizes. Directories are shown in blue.
HELP

def diskusage_menu
  clear_image

  lines = []
  lines << "System / Disk Usage".bd.fg(254)
  lines << ""
  lines << "s".bd.fg(112) + "  System info"
  lines << "d".bd.fg(112) + "  Disk usage analyzer"
  lines << ""
  lines << "q/ESC: close".fg(240)

  @pR.update = true
  @pR.say(lines.join("\n"))

  chr = getchr
  case chr
  when 's'
    system_info
  when 'd'
    diskusage_browse(Dir.pwd)
  when 'q', 'ESC'
    @pR.update = true
    refresh
    render
  end
end

def diskusage_browse(start_dir)
  browse_dir = start_dir
  sel = 0
  offset = 0
  cached = {} # dir => entries

  loop do
    entries = cached[browse_dir] || diskusage_scan(browse_dir)
    cached[browse_dir] = entries if entries
    entries ||= []
    total = entries.sum { |e| e[:size] }
    max_size = entries.map { |e| e[:size] }.max || 1
    page_h = @pR.h - 6
    page_h = 1 if page_h < 1

    sel = 0 if entries.empty?
    sel = entries.size - 1 if sel >= entries.size && !entries.empty?

    offset = sel - page_h + 1 if sel >= offset + page_h
    offset = sel if sel < offset
    offset = 0 if offset < 0

    visible = entries[offset, page_h] || []

    lines = []
    lines << "Disk Usage".bd.fg(254) + "  " + browse_dir.fg(240)
    lines << ("Total: " + diskusage_human(total)).fg(249)
    lines << ""

    bar_width = @pR.w - 30
    bar_width = 10 if bar_width < 10

    visible.each_with_index do |entry, i|
      idx = offset + i
      ratio = max_size > 0 ? entry[:size].to_f / max_size : 0
      filled = (ratio * bar_width).round
      bar = "\u2588" * filled + "\u2591" * (bar_width - filled)

      name_color = entry[:dir] ? 69 : 249
      size_str = diskusage_human(entry[:size]).rjust(9)
      name = entry[:name]
      name += "/" if entry[:dir]

      line = bar.fg(entry[:dir] ? 69 : 243) + " " +
             size_str.fg(156) + " " +
             name.fg(name_color)
      line = idx == sel ? line.ul : line
      lines << line
    end

    if entries.size > page_h
      lines << ""
      lines << "(#{sel + 1}/#{entries.size})".fg(240)
    end

    @pR.update = true
    @pR.say(lines.join("\n"))

    chr = getchr
    case chr
    when 'j', 'DOWN'
      sel = (sel + 1) % entries.size unless entries.empty?
    when 'k', 'UP'
      sel = (sel - 1) % entries.size unless entries.empty?
    when 'ENTER'
      next if entries.empty?
      entry = entries[sel]
      if entry[:dir]
        browse_dir = File.join(browse_dir, entry[:name])
        sel = 0
        offset = 0
      end
    when 'LEFT', 'h'
      parent = File.dirname(browse_dir)
      if parent != browse_dir
        browse_dir = parent
        sel = 0
        offset = 0
      end
    when 'q', 'ESC'
      break
    end
  end

  @pR.update = true
  refresh
  render
end

def diskusage_scan(dir)
  return [] unless Dir.exist?(dir)

  entries = []
  # Scan entries one by one for progress and cancellability
  children = begin
    Dir.entries(dir).reject { |e| e == '.' || e == '..' }
  rescue
    return []
  end

  children.each_with_index do |name, i|
    # Check for ESC to cancel
    begin
      $stdin.read_nonblock(1)
      $stdin.read_nonblock(16) rescue nil
      @pB.say("Scan cancelled.".fg(220))
      return entries.sort_by { |e| -e[:size] }
    rescue IO::WaitReadable, EOFError
      # No keypress, continue scanning
    end

    @pB.update = true
    @pB.say(" Scanning #{i + 1}/#{children.size}: #{name}")
    @pB.refresh

    path = File.join(dir, name)
    is_dir = File.directory?(path) rescue false
    begin
      if is_dir
        out = `du -sb #{Shellwords.escape(path)} 2>/dev/null`.strip
        size = out.split("\t").first.to_i
      else
        size = File.size(path) rescue 0
      end
    rescue
      size = 0
    end
    entries << { name: name, size: size, dir: is_dir }
  end

  @pB.say("")
  entries.sort_by { |e| -e[:size] }
end

def diskusage_human(bytes)
  if bytes >= 1024 * 1024 * 1024
    format("%.1f GB", bytes.to_f / (1024 * 1024 * 1024))
  elsif bytes >= 1024 * 1024
    format("%.1f MB", bytes.to_f / (1024 * 1024))
  elsif bytes >= 1024
    format("%.1f KB", bytes.to_f / 1024)
  else
    "#{bytes} B"
  end
end
