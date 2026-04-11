# @name: Bookmarks
# @description: Quick directory bookmarks with fuzzy jump
# @key: F6

BOOKMARKS_FILE = File.expand_path('~/.rtfm/bookmarks.txt')

KEYMAP['F6'] = :bookmark_menu

PLUGIN_HELP['Bookmarks'] = <<~HELP
  Quick directory bookmarks with fuzzy filtering.

  Press F6 to open the bookmark manager.

  #{"Commands:".bd}
    a       Add current directory to bookmarks
    d       Delete selected bookmark
    j/k     Navigate up/down
    ENTER   Jump to selected directory
    /       Filter bookmarks (fuzzy search)
    q/ESC   Close

  #{"Difference from marks:".bd}
    Marks (m/') are single-letter slots (a-z) that
    save a directory path for quick recall. You get
    26 slots max, and must remember which letter
    maps to which directory.

    Bookmarks are an unlimited named list of
    directories with fuzzy filtering. Better for
    large collections of frequently visited paths.
    They persist in ~/.rtfm/bookmarks.txt.
HELP

def load_bookmarks
  return [] unless File.exist?(BOOKMARKS_FILE)
  File.readlines(BOOKMARKS_FILE).map(&:strip).reject(&:empty?)
end

def save_bookmarks(bookmarks)
  File.write(BOOKMARKS_FILE, bookmarks.join("\n") + "\n")
end

def bookmark_menu
  clear_image

  sel = 0
  filter = nil

  loop do
    bookmarks = load_bookmarks
    visible = filter ? bookmarks.select { |b| b.downcase.include?(filter.downcase) } : bookmarks

    lines = []
    lines << "Bookmarks".bd.fg(254)
    lines << "filter: #{filter}".fg(240) if filter
    lines << ""

    if visible.empty?
      lines << (filter ? "No matches." : "No bookmarks yet.").fg(240)
    else
      # Find common prefix to dim shared parts
      common = ""
      if visible.size > 1
        parts = visible.map { |b| b.split('/') }
        min_len = parts.map(&:size).min
        min_len.times do |i|
          break unless parts.all? { |p| p[i] == parts[0][i] }
          common += parts[0][i] + '/'
        end
      end

      visible.each_with_index do |path, i|
        idx = bookmarks.index(path)
        prefix = common.empty? ? "" : path[0, common.length].fg(240)
        suffix = common.empty? ? path.fg(112) : path[common.length..].fg(112)
        line = "#{idx.to_s.rjust(2).fg(240)} #{prefix}#{suffix}"
        line = i == sel ? line.ul : line
        lines << line
      end
    end

    lines << ""
    lines << "a".bd.fg(112) + ":add  " + "d".bd.fg(112) + ":del  " +
             "/".bd.fg(112) + ":filter  " + "ENTER".bd.fg(112) + ":jump  " +
             "q".bd.fg(112) + ":close"

    @pR.update = true
    @pR.say(lines.join("\n"))

    chr = getchr
    case chr
    when 'q', 'ESC'
      break
    when 'j', 'DOWN'
      sel = visible.empty? ? 0 : (sel + 1) % visible.size
    when 'k', 'UP'
      sel = visible.empty? ? 0 : (sel - 1) % visible.size
    when 'a'
      cwd = Dir.pwd
      unless bookmarks.include?(cwd)
        bookmarks << cwd
        save_bookmarks(bookmarks)
        @pB.say("Bookmarked: #{cwd}")
      else
        @pB.say("Already bookmarked.")
      end
    when 'd'
      unless visible.empty?
        path = visible[sel]
        bookmarks.delete(path)
        save_bookmarks(bookmarks)
        sel = [sel, visible.size - 2].max
        sel = 0 if sel < 0
        @pB.say("Removed: #{path}")
      end
    when 'ENTER'
      unless visible.empty?
        path = visible[sel]
        if Dir.exist?(path)
          Dir.chdir(path)
          @pB.say("Jumped to: #{path}")
          break
        else
          @pB.say("Directory not found: #{path}")
        end
      end
    when '/'
      input = @pCmd.ask('Filter: ', filter || '')
      filter = input.strip.empty? ? nil : input.strip
      sel = 0
    end
  end

  @pR.update = true
  refresh
  render
end
