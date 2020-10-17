#!/usr/bin/env ruby
# encoding: utf-8

# Script info {{{1
# RTFM - [Ruby|Ruddy|Rough] Terminal File Manager
# Language:   Pure Ruby
# Author:     Geir Isene <g@isene.com>
# Web_site:   http://isene.com/
# Github:     https://github.com/isene/RTFM
# License:    I release all copyright claims. 
#             This code is in the public domain.
#             Permission is granted to use, copy modify, distribute, and
#             sell this software for any purpose. I make no guarantee
#             about the suitability of this software for any purpose and
#             I am not liable for any damages resulting from its use.
#             Further, I am under no obligation to maintain or extend
#             this software. It is provided on an 'as is' basis without
#             any expressed or implied warranty.


# BASIC SETUP {{{1
# Require {{{2
require 'curses'
include Curses

# Curses setup {{{2
Curses.init_screen
Curses.start_color
Curses.curs_set(0)
Curses.noecho
Curses.cbreak
Curses.stdscr.keypad = true

# Set basic variables {{{2
@w3mimgdisplay = "/usr/lib/w3m/w3mimgdisplay"

# Set default colors {{{2
init_pair(7, 7, 0)        # Default
init_pair(255, 232, 249)  # Top Windows
init_pair(254, 250, 0)    # Bottom Windows

# Import LS_COLORS {{{2
LScolors = `echo $LS_COLORS`

# FUNCTIONS {{{1
# Get the color for the filetype from imported LS_COLORS {{{2
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

# List content of a directory (both left and right windows) {{{2
def list_dir(win, left, files)
  left ? ix = @index : ix = 0
  files.each.with_index(0) do |str, index|

    left ? str_path = str : str_path = "#{@selected}/#{str}" 
    # Ensure only the items fitting on the screen will be drawn (win_left)
    if index > ix - win.maxy + 3
      # Determine the filetype of the item {{{3
      ftype = ""
      ftype = str.match(/\.([^.]*$)/)[1] if str.match?(/\.([^.]*$)/)
      
      # Set special filetypes (sequence matters)
      ftype = "bd" if File.blockdev?(str_path)
      ftype = "cd" if File.chardev?(str_path)
      ftype = "pi" if File.pipe?(str_path)
      ftype = "st" if File.sticky?(str_path)
      ftype = "so" if File.socket?(str_path)
      ftype = "ex" if File.executable?(str_path)
      ftype = "di" if File.directory?(str_path)
      ftype = "ln" if File.symlink?(str_path) 
      # Checking if item is an orphaned link
      begin
        File.stat(str_path)
      rescue
        ftype = "or" 
      end

      # Set the colors for the filetypes, print to window {{{3 
      # Set default colors
      fg = 7; bold = 0; bg = 0
      
      # Get color for filetype from imported LS_COLORS
      fg, bold = get_ls_color(ftype) unless ftype == ""
      init_pair(fg, fg, bg)

      # Set color for the item and add "/" if directory
      file_marker = color_pair(fg)
      file_marker = file_marker | Curses::A_BOLD if bold == 1
      file_marker = file_marker | Curses::A_UNDERLINE if index == @index and left
      File.directory?(str) ? dir = "/" : dir = ""
      str = fspes[index] + "  " + str if @lslong
      
      # Implement the color (and bold), clear to end-of-line and add newline
      win.attron(file_marker) { win << str + dir }
      clrtoeol
      win << "\n"
    end
  end
end

# Open selected item (when pressing Right) {{{2
def open_selected()
  if File.directory?(@selected) # Rescue for permission error
    begin
      Dir.chdir(@selected)
      # Set index to stored value if directory has been visited
      @directory.key?(Dir.pwd) ? @index = @directory[Dir.pwd] : @index = 0
    rescue
    end
  else
    begin
      if File.read(@selected).force_encoding("UTF-8").valid_encoding?
        system("$EDITOR #{@selected_safe}")
      else
          begin
            system("run-mailcap #{@selected_safe}")
          rescue
            system("xdg-open #{@selected_safe}")
          end
        end
      Curses.refresh
    rescue
    end
  end
end

# Show the selected image in the right window (pass "clear" to clear the window) {{{2
def image_show(image)
  begin
    terminfo    = `xwininfo -id $(xdotool getactivewindow)`
    term_w      = terminfo.match(/Width: (\d+)/)[1].to_i
    term_h      = terminfo.match(/Height: (\d+)/)[1].to_i
    char_w      = term_w / Curses.cols
    char_h      = term_h / Curses.lines
    img_x       = char_w * (Curses.cols / 3 + 1)
    img_y       = char_h * 2
    img_max_w   = char_w * (2 * Curses.cols / 3 - 2)
    img_max_h   = char_h * (Curses.lines - 5)
    if image == "clear"
      img_max_w += 5
      img_max_h += 5
      `imgw3m.sh CLEAR #{img_x} #{img_y} #{img_max_w} #{img_max_h} 2>/dev/null`
    else
      img_w,img_h = `identify -format "%[fx:w]x%[fx:h]" #{image} 2>/dev/null`.split('x')
      img_w       = img_w.to_i
      img_h       = img_h.to_i
      if img_w > img_max_w
        img_h = img_h * img_max_w / img_w 
        img_w = img_max_w
      end
      if img_h > img_max_h
        img_w = img_w * img_max_h / img_h
        img_h = img_max_h
      end
      `imgw3m.sh #{image} #{img_x} #{img_y} #{img_w} #{img_h} 2>/dev/null`
      #w3m_cmd     = "0;1;#{img_x};#{img_y};#{img_w};#{img_h};;;;;#{image}\\n4;\\n3;"
      #`echo -e "#{w3m_cmd}"|#{@w3mimgdisplay}`
    end
  rescue
    win_right << "Error showing image"
  end
end

# Show contents in the right window {{{2
def win_right_show(win_right)
  # Right window (viewer)
  win_right.setpos(0, 0)
  (win_right.maxy - win_right.cury).times {win_right.deleteln()}
  win_right.refresh
  win_right.setpos(0, 0)
  # Clear for any previously showing image
  image_show("clear")
  # Determine the specific programs to open/show content {{{3
  begin
    # Directories {{{4
    if File.directory?(@selected)
      ls_cmd = "ls #{@lsall} #{@selected_safe} --group-directories-first"
      files  = `#{ls_cmd}`.split("\n")
      list_dir(win_right, false, files)
    # Text {{{4
    # View the file as text if it is utf-8
    elsif File.read(@selected).force_encoding("UTF-8").valid_encoding?
      win_right << `cat #{@selected_safe} 2>/dev/null`
    # PDF {{{4
    elsif @selected.match(/\.pdf$|\.ps$/)
      win_right << `pdftotext -f 1 -l 4 #{@selected_safe} - 2>/dev/null | less`
    # Open/LibreOffice {{{4
    elsif @selected.match(/\.odt$|\.odc$|\.odp$/)
      win_right << `unoconv --stdout #{@selected_safe} 2>/dev/null`
    # OOXML {{{4
    elsif @selected.match(/\.docx$|\.xlsx$|\.pptx$/)
      win_right << `docx2txt #{@selected_safe} - 2>/dev/null`
    # MS doc {{{4
    elsif @selected.match(/\.doc$/)
      win_right << `catdoc #{@selected_safe} 2>/dev/null`
    # MS xls {{{4
    elsif @selected.match(/\.xls$/)
      win_right << `xls2csv #{@selected_safe} 2>/dev/null`
    # MS ppt {{{4
    elsif @selected.match(/\.ppt$/)
      win_right << `catppt #{@selected_safe} 2>/dev/null`
    # Images {{{4
    elsif @selected.match(/\.jpg$|\.jpeg$|\.png$|\.bmp$|\.gif$/)
      image_show(@selected_safe)
    end
  rescue
  end
  clrtoeol
  (win_right.maxy - win_right.cury).times {win_right.deleteln()}
  win_right.refresh
end 

# INITIALIZE VARIABLE FOR WINDOWS {{{1
# Initialize the directory hash -
# for remembering index for every directory visited
@directory = {}

# Set chosen item to first
@index = 0

# Set short form ls (toggled by pressing "l")
@lslong = false

# Set "ls -a" to false (toggled by pressing "a")
@lsall = ""

# MAIN PROGRAM {{{1
begin
  # Create the four windows/panels {{{2
  win_top    = Curses::Window.new(1, 0, 0, 0)
  win_bottom = Curses::Window.new(2, 0, Curses.lines - 2, 0)
  win_left   = Curses::Window.new(Curses.lines - 4, Curses.cols / 3 - 1, 2, 1)
  win_right  = Curses::Window.new(Curses.lines - 4, 0, 2, Curses.cols / 3 + 1)

  # Core loop {{{2
  loop do
    # Get files in current directory, set selected item {{{3
    ls_cmd    = "ls #{@lsall} -X --group-directories-first"
    files     = `#{ls_cmd}`.split("\n")
    ls_cmd   += %q[ -lh | awk '{printf "%s%4s%7s", $1,$2,$5"\n"}']
    fspes     = `#{ls_cmd}`.split("\n").drop(1)
    @selected = files[@index]
    @selected = "" if @selected == nil
    @selected_safe = "'#{@selected}'"

    # Safety measure - correct index overflows {{{3
    max_index = files.size - 1
    min_index = 0
    @index = max_index if @index > max_index

    # Top window (info line) {{{3
    win_top.setpos(0,0)
    toptext  = " Path: " + Dir.pwd + "/" + @selected
    begin
      toptext += " (#{fspes[@index].gsub(/ .* /, ' ')})" 
    rescue
    end
    toptext += " " * (Curses.cols - toptext.length)
    win_top.attron(color_pair(255) | Curses::A_BOLD) { win_top << toptext }
    win_top.refresh

    # Bottom window (command line) {{{3
    win_bottom.setpos(0,0)
    bottomtext = ": for command (use @s for selected item)"
    win_bottom.attron(color_pair(254) | Curses::A_DIM) { win_bottom << "─" * win_bottom.maxx }
    win_bottom.attron(color_pair(254) | Curses::A_DIM) { win_bottom << bottomtext }
    win_bottom.refresh

    # Left window (browser) {{{3
    win_left.setpos(0,0)
    list_dir(win_left, true, files)
    (win_left.maxy - win_left.cury).times {win_left.deleteln()}
    win_left.refresh

    # Right window (content viewer) {{{3
    win_right_show(win_right)

    # Get key from user {{{3
    # Curses.getch blanks out win_top
    # win_left.getch makes Curses::KEY_DOWN etc not work
    # Therefore resorting to the generic method
    case STDIN.getc
    when "\e"            # ANSI escape sequence
      case $stdin.getc
      when '['           # CSI
        case $stdin.getc
        when 'A' then @index = @index <= min_index ? max_index : @index - 1
        when 'B' then @index = @index >= max_index ? min_index : @index + 1
        when 'C' 
          # Store index of this directory before leaving
          @directory[Dir.pwd] = @index
          open_selected()
        when 'D' 
          # Store index of this directory before leaving
          @directory[Dir.pwd] = @index
          Dir.chdir("..")
          # Set index to stored value if directory has been visited
          @directory.key?(Dir.pwd) ? @index = @directory[Dir.pwd] : @index = 0
        when '5' 
          @index -= win_left.maxy - 2
          @index = min_index if @index < min_index
        when '6'
          @index += win_left.maxy - 2
          @index = max_index if @index > max_index
        when '7' then @index = min_index
        when '8' then @index = max_index
        end
      end
    when ':' # Enter "command mode" in the bottom window - tries to execute the given command
      win_bottom.clear
      win_bottom.attron(color_pair(254) | Curses::A_DIM) { win_bottom << "─" * win_bottom.maxx }
      win_bottom.attron(color_pair(254) | Curses::A_DIM) { win_bottom << " : " }
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
        STDIN.getc
        win_bottom.refresh
      end
      # Remove cursor and display no keys pressed
      Curses.curs_set(0)
      Curses.noecho
    when 'l' then @lslong = !@lslong
    when 'a' then @lsall == "" ? @lsall = "-a" : @lsall = ""
    when 'q' then exit 0
    end
  end
ensure
  # On exit: close curses, clear terminal {{{2
  close_screen
  `clear`
end

# vim modeline {{{1
# vim: set sw=2 sts=2 et fdm=marker fillchars=fold\:\ :
