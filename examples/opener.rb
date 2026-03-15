# @name: Opener
# @description: Custom file openers by extension (override default open behavior)
# @key: RIGHT/l (overrides move_right)

require 'shellwords'

# User-configurable openers hash:
# Extension => command string (use %f for file path)
PLUGIN_HELP['Opener'] = <<~HELP
  Custom file openers by extension.

  Overrides RIGHT/l to check selected files against
  a list of custom openers before using the default
  open behavior.

  #{"Configuration:".b}
    Edit the CUSTOM_OPENERS hash in the plugin file
    (~/.rtfm/plugins/opener.rb):

    CUSTOM_OPENERS = {
      '.md'  => 'glow %f',
      '.pdf' => 'zathura %f',
      '.hl'  => 'hyperlist %f',
    }

    Use %f as placeholder for the file path.

  #{"How it works:".b}
    When you press RIGHT or l on a file, the plugin
    checks if its extension matches any entry in
    CUSTOM_OPENERS. If yes, it launches that program
    interactively. If no match, the normal RTFM
    open behavior is used.
HELP

CUSTOM_OPENERS = {
  # '.md'  => 'glow %f',        # Example: markdown viewer
  # '.pdf' => 'zathura %f',     # Example: PDF viewer
  # '.csv' => 'visidata %f',    # Example: CSV explorer
  # '.hl'  => 'hyperlist %f',   # Example: HyperList files
}

def custom_open
  # Check if the selected file matches any registered extension
  ext = CUSTOM_OPENERS.keys.find { |e| @selected.end_with?(e) }

  unless ext
    # No custom opener, fall back to original move_right
    move_right
    return
  end

  cmd = CUSTOM_OPENERS[ext].gsub('%f', Shellwords.escape(@selected))

  # Launch the program interactively (same pattern as RTFM's interactive handling)
  @external_program_running = true
  system("stty #{ORIG_STTY} < /dev/tty")
  system('stty sane < /dev/tty')
  system('clear < /dev/tty > /dev/tty')
  Cursor.show

  pid = Process.spawn(cmd,
                      in:  '/dev/tty',
                      out: '/dev/tty',
                      err: '/dev/tty')
  begin
    Process.wait(pid)
  rescue Interrupt
    Process.kill('TERM', pid) rescue nil
    retry
  ensure
    @external_program_running = false
  end

  # Restore RTFM's terminal state
  system('stty raw -echo isig < /dev/tty')
  $stdin.raw!
  $stdin.echo = false
  Cursor.hide
  Rcurses.clear_screen
  refresh
  render
end

KEYMAP['RIGHT']   = :custom_open
KEYMAP['l']       = :custom_open
KEYMAP['C-RIGHT'] = :custom_open
