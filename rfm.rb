#!/usr/bin/env ruby

require 'curses'
include Curses

# Initial setup
Curses.init_screen
Curses.start_color
Curses.curs_set(0)
Curses.noecho
Curses.cbreak
Curses.stdscr.keypad = true

# Set default colors
init_pair(7, 7, 0)      # Default
init_pair(255, 0, 250)  # Top/Bottom windows

# Import LS_COLORS
LScolors = `echo $LS_COLORS`

# Get the color for the filetype from imported LS_COLORS
def get_ls_color(type)
  bold  = 0
  begin
    color = LScolors.match(/#{type}=\d*;\d*;(\d*)/)[1]
    bold  = 1 if LScolors.match(/#{type}=\d*;\d*;\d*;1/)
  rescue
    color = 7
  end
  return color.to_i, bold
end

# Open selected item (when pressing Enter or Right)
def open_selected()
  if File.directory?(@selected) # Rescue for permission error
    begin
      Dir.chdir(@selected)
      @directory.key?(Dir.pwd) ? @index = @directory[Dir.pwd] : @index = 0
    rescue
    end
  else
    begin
      if File.read(@selected).force_encoding("UTF-8").valid_encoding?
        system("$EDITOR #{@selected}")
      else
          begin
            system("run-mailcap #{@selected}")
          rescue
            system("xdg-open #{@selected}")
          end
        end
      Curses.refresh
    rescue
    end
  end
end

# Initialize the directory hash
@directory = {}

# Set chosen item to first
@index = 0

# Main program
begin
  # Create the four windows/panels
  win_top    = Curses::Window.new(2, 0, 0, 0)
  win_bottom = Curses::Window.new(2, 0, Curses.lines - 2, 0)
  win_left   = Curses::Window.new(Curses.lines - 4, Curses.cols / 4 - 1, 2, 1)
  win_right  = Curses::Window.new(Curses.lines - 4, 0, 2, Curses.cols / 4 + 1)

  # Core loop
  loop do
    # Get files in current directory, set selected item
    files = `ls`.split("\n").sort
    @selected = files[@index]
    @selected = "" if @selected == nil

    # Top window (info line)
    win_top.clear
    win_top.setpos(0,0)
    perm = ""
    begin
      perm = File.stat(@selected).mode.to_s(8)
    rescue
    end
    toptext = "Path: " + Dir.pwd + "/" + @selected + " (#{perm})"
    topline = toptext + " " * (win_top.maxx - toptext.length)
    win_top.attron(color_pair(7) | Curses::A_BOLD) { win_top << topline }
    win_top << "─" * win_top.maxx

    # Bottom window (command line)
    win_bottom.clear
    win_bottom.setpos(0,0)
    win_bottom << "─" * win_bottom.maxx
    win_bottom << ": for command (use @s for selected item)"

    # Left window (browser)
    #win_left.clear
    win_left.setpos(0,0)
    max_index = files.size - 1
    min_index = 0
    files.each.with_index(0) do |str, index|
      # Ensure only the items fitting on the screen will be drawn
      if index > @index - win_left.maxy + 3
        # Determine the filetype of the item
        ftype = ""
        ftype = str.match(/\.([^.]*$)/)[1] if str.match?(/\.([^.]*$)/)
        
        # Set special filetypes (sequence matters)
        ftype = "bd" if File.blockdev?(str)
        ftype = "cd" if File.chardev?(str)
        ftype = "pi" if File.pipe?(str)
        ftype = "st" if File.sticky?(str)
        ftype = "so" if File.socket?(str)
        ftype = "ex" if File.executable?(str)
        ftype = "di" if File.directory?(str)
        ftype = "ln" if File.symlink?(str) 
        # Checking if item is an orphaned link
        begin
          File.stat(str)
        rescue
          ftype = "or" 
        end

        # Set default colors
        fg = 7; bold = 0; bg = 0
        
        # Get color for filetype from imported LS_COLORS
        fg, bold = get_ls_color(ftype) unless ftype == ""
        init_pair(fg, fg, bg)

        # Set color for the item and add "/" if directory
        file_marker = color_pair(fg)
        file_marker = file_marker | Curses::A_BOLD if bold == 1
        file_marker = file_marker | Curses::A_UNDERLINE if index == @index
        File.directory?(str) ? dir = "/" : dir = ""
        
        # Implement the color (and bold), clear to end-of-line and add newline
        win_left.attron(file_marker) { win_left << str + dir }
        clrtoeol
        win_left << "\n"
      end
    end
    (win_left.maxy - win_left.cury).times {win_left.deleteln()}

    # Right window (viewer)
    win_right.clear
    win_right.setpos(0, 0)
    # View the file if it is utf-8
    begin
      win_right << `cat #{@selected}` if File.read(@selected).force_encoding("UTF-8").valid_encoding?
    rescue
    end
    win_left.refresh
    win_right.refresh
    win_top.refresh
    win_bottom.refresh

    # Get key from user
    #ch = Curses.getch   # This blanks out win_top
    #ch = win_left.getch # This makes Curses::KEY_DOWN etc not work
    #case ch
    #  when Curses::KEY_UP, ?j
    #    @index = @index <= min_index ? max_index : @index - 1
    #  when Curses::KEY_DOWN, ?k
    #    @index = @index >= max_index ? min_index : @index + 1
    #  when Curses::KEY_ENTER, Curses::KEY_RIGHT
    #    open_selected()
    #  when Curses::KEY_LEFT
    #    Dir.chdir("..")
    #    @index = 0
    #  when 'q' then exit 0
    #end
    case STDIN.getc      # Therefore resorting to the generic method
    when "\e"            # ANSI escape sequence
      case $stdin.getc
      when '['           # CSI
        case $stdin.getc
        when 'A' then @index = @index <= min_index ? max_index : @index - 1
        when 'B' then @index = @index >= max_index ? min_index : @index + 1
        when 'C' 
          @directory[Dir.pwd] = @index
          open_selected()
        when 'D' 
          @directory[Dir.pwd] = @index
          Dir.chdir("..")
          @directory.key?(Dir.pwd) ? @index = @directory[Dir.pwd] : @index = 0
        end
      end
    when ':' # Enter "command mode" in the bottom window - tries to execute the given command
      win_bottom.clear
      win_bottom << "─" * win_bottom.maxx
      win_bottom << ": "
      win_bottom.refresh
      win_bottom.setpos(3,2)
      @s = @selected
      # Display cursor and the text entered
      Curses.curs_set(1)
      Curses.echo
      cmd = win_bottom.getstr
      # Subsitute any '@s' with the selected item
      # 'rm @s' deletes the selected item 
      cmd.gsub!(/@s/, @selected)
      begin
        `#{cmd}`
      rescue
        win_bottom << "Failed to execute command (#{cmd})"
        win_bottom.getch
        win_bottom.refresh
      end
      # Remove cursor and display no keys pressed
      Curses.curs_set(0)
      Curses.noecho
    when 'q' then exit 0
    end
  end
ensure
  # On exit: close curses, clear terminal
  close_screen
  `clear`
end