# RTFM Plugin Development Guide

Extend RTFM with custom preview handlers and key bindings.

## Plugin System Overview

RTFM supports two types of plugins:

1. **Preview Handlers** (`~/.rtfm/plugins/preview.rb`) - Custom file type previews
2. **Key Bindings** (`~/.rtfm/plugins/keys.rb`) - Custom commands and key mappings

Both are Ruby files evaluated in RTFM's context, giving you full access to RTFM's internals.

## Preview Handlers

### Location

`~/.rtfm/plugins/preview.rb`

### Syntax

```ruby
# extension1, extension2, extension3 = command with @s placeholder
#
# @s is replaced with shell-escaped filename

# Examples:
txt, log = bat -n --color=always @s
md = pandoc @s -t plain
pdf = pdftotext -f 1 -l 4 @s -
json = jq . @s
xml = xmllint --format @s
```

### How It Works

1. RTFM matches file extension
2. Replaces `@s` with escaped filename
3. Executes command
4. Displays output in right pane

### Examples

#### Syntax Highlighting

```ruby
# Programming languages
rb, py, js = bat -n --color=always @s
c, cpp, h = highlight -O ansi --force --line-numbers @s
```

#### Document Formats

```ruby
# Markdown
md, markdown = pandoc @s -t plain

# PDF
pdf = pdftotext -f 1 -l 10 @s -

# LibreOffice
odt = odt2txt @s
ods = ssconvert --export-type=Gnumeric_stf:stf_csv @s fd://1

# MS Office
docx = docx2txt @s
xlsx = ssconvert --export-type=Gnumeric_stf:stf_csv @s fd://1
```

#### Data Formats

```ruby
# JSON with syntax highlighting
json = jq -C . @s

# YAML
yaml, yml = bat -l yaml @s

# XML
xml = xmllint --format @s | bat -l xml
```

#### Media Info

```ruby
# Video metadata
mp4, mkv, avi = ffprobe -hide_banner @s 2>&1

# Audio metadata
mp3, flac = mediainfo @s

# Image metadata (already built-in, but you can override)
# png, jpg = identify -verbose @s
```

#### Archives (Preview Contents)

Built-in support for: zip, tar, gz, bz2, xz, rar, 7z

Override if needed:
```ruby
zip = unzip -l @s
tar = tar -tvf @s
```

### Complex Preview Handlers

For more complex logic, use Ruby in preview.rb:

```ruby
# Define handler as Ruby code instead of shell command
PREVIEW_HANDLERS << [/\.log$/i, -> {
  # Custom Ruby handler
  content = File.read(@selected).lines.last(50).join
  @pR.say("Last 50 lines:\n" + content)
}]
```

## Key Bindings

### Location

`~/.rtfm/plugins/keys.rb`

### Basic Syntax

```ruby
# Add or override key binding
KEYMAP['X'] = :my_handler

# Define handler method
def my_handler(_chr)
  @pB.say("You pressed X!")
end
```

### Available Panes

| Variable | Description |
|----------|-------------|
| `@pT` | Top pane (path/metadata) |
| `@pL` | Left pane (file list) |
| `@pR` | Right pane (preview) |
| `@pB` | Bottom pane (status) |
| `@pCmd` | Command prompt pane |
| `@pSearch` | Search prompt pane |
| `@pAI` | AI chat pane |
| `@pRuby` | Ruby debug pane |

### Pane Methods

```ruby
# Display text
@pR.say("Hello world")
@pB.say("Status message")

# Ask for input
answer = @pCmd.ask('Enter value: ', 'default')

# Clear pane
@pR.clear

# Update pane (mark for refresh)
@pR.update = true

# Force immediate refresh
@pR.refresh
@pR.full_refresh  # Complete redraw
```

### Available Variables

| Variable | Type | Description |
|----------|------|-------------|
| `@selected` | String | Currently selected file/dir path |
| `@tagged` | Array | Paths of tagged items |
| `@marks` | Hash | Bookmarks {'a' => '/path', ...} |
| `@files` | Array | Current directory file list |
| `@index` | Integer | Selected item index |
| `@w` / `@h` | Integer | Terminal width/height |
| `@preview` | Boolean | Preview enabled? |
| `@showimage` | Boolean | Image preview enabled? |
| `@trash` | Boolean | Trash bin enabled? |

### Helper Functions

#### Execute Commands

```ruby
# Capture output (auto-shows errors in right pane)
output = command("ls -la", timeout: 5)
@pR.say(output)

# Fire-and-forget (shows errors if any)
shell("mv file1 file2", background: false)

# Show both stdout and stderr in right pane
shellexec("grep -r pattern .")
```

#### File Operations

```ruby
# Check if file exists
File.exist?(@selected)

# Get file size
File.size(@selected)

# Read file
content = File.read(@selected)

# Write file
File.write('/tmp/output.txt', content)
```

## Example Plugins

### Example 1: Git Commit Shortcut

```ruby
# ~/.rtfm/plugins/keys.rb

KEYMAP['C-G'] = :git_quick_commit

def git_quick_commit
  message = @pCmd.ask('Commit message: ', '')
  return if message.strip.empty?

  shellexec("git add . && git commit -m '#{message}' && git push")
  @pB.say("Git commit and push completed")
end
```

**Usage:** Press `Ctrl-g`, enter message, done!

### Example 2: Quick Note Taker

```ruby
KEYMAP['C-N'] = :quick_note

def quick_note
  note = @pCmd.ask('Note: ', '')
  return if note.strip.empty?

  File.open("#{Dir.home}/notes.txt", 'a') do |f|
    f.puts "[#{Time.now}] #{note}"
  end

  @pB.say("Note saved to ~/notes.txt")
end
```

### Example 3: Batch File Converter

```ruby
KEYMAP['C-C'] = :convert_images

def convert_images
  return @pB.say("Tag images first!") if @tagged.empty?

  format = @pCmd.ask('Convert to (png/jpg/webp): ', 'png')

  @tagged.each do |file|
    next unless file.match(/\.(jpg|png|gif|bmp)$/i)

    output = file.sub(/\.\w+$/, ".#{format}")
    command("convert #{Shellwords.escape(file)} #{Shellwords.escape(output)}")
  end

  @pB.say("Converted #{@tagged.size} images to #{format}")
  @tagged.clear
  @pL.update = true
end
```

### Example 4: Custom File Opener

```ruby
KEYMAP['O'] = :open_with

def open_with
  program = @pCmd.ask('Open with: ', 'vim')
  return if program.strip.empty?

  escaped = Shellwords.escape(@selected)

  # Set flag to prevent SIGWINCH redrawing over program
  @external_program_running = true

  system("stty sane < /dev/tty")
  system("clear < /dev/tty > /dev/tty")
  Cursor.show

  system("#{program} #{escaped}")

  @external_program_running = false

  # Restore terminal for RTFM
  system('stty raw -echo isig < /dev/tty')
  $stdin.raw!
  $stdin.echo = false
  Cursor.hide
  Rcurses.clear_screen
  refresh
  render
end
```

### Example 5: Directory Size Calculator

```ruby
KEYMAP['#'] = :calc_dir_size

def calc_dir_size
  return @pB.say("Select a directory") unless File.directory?(@selected)

  @pR.say("Calculating size...")

  output = command("du -sh #{Shellwords.escape(@selected)}")
  size = output.split("\t").first

  @pR.say("Directory Size\n\n#{@selected}\n\n#{size}")
end
```

## Advanced Techniques

### Launching External TUI Programs

For full-screen terminal programs (vim, htop, etc.):

```ruby
def launch_external_program(cmd)
  @external_program_running = true

  # Save and restore terminal state
  system("stty -g < /dev/tty > /tmp/rtfm_stty_$$")
  system('stty sane < /dev/tty')
  system('clear < /dev/tty > /dev/tty')
  Cursor.show

  # Spawn on real tty
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

  # Restore RTFM terminal state
  system('stty raw -echo isig < /dev/tty')
  $stdin.raw!
  $stdin.echo = false
  Cursor.hide
  Rcurses.clear_screen
  refresh
  render
end
```

### Working with Tagged Items

```ruby
def process_tagged_items
  if @tagged.empty?
    @pB.say("No items tagged")
    return
  end

  @tagged.each do |item|
    # Process each item
    if File.file?(item)
      # Handle file
    elsif File.directory?(item)
      # Handle directory
    end
  end

  # Clear tags after processing
  @tagged.clear
  @pL.update = true
end
```

### Interactive Prompts

```ruby
def interactive_handler
  # Text input
  text = @pCmd.ask('Enter text: ', 'default value')

  # Number input
  num = @pCmd.ask('Enter number: ', '10').to_i

  # Yes/no confirmation
  confirm = @pCmd.ask('Proceed? (y/n): ', 'y')
  return unless confirm =~ /^y/i

  # Process...
end
```

### Updating Display

```ruby
def custom_display
  # Update right pane
  @pR.clear
  @pR.say("Custom content here")
  @pR.update = true

  # Update bottom status
  @pB.say("Operation complete")
  @pB.update = true

  # Trigger render
  render
end
```

## Plugin Best Practices

### 1. Check Prerequisites

```ruby
def my_handler
  unless cmd?('required-program')
    @pB.say("Error: required-program not installed")
    return
  end

  # Continue...
end
```

### 2. Handle Errors Gracefully

```ruby
def safe_handler
  begin
    # Your code
  rescue => e
    @pB.say("Error: #{e.message}")
  end
end
```

### 3. Provide Feedback

```ruby
def verbose_handler
  @pB.say("Processing...")

  # Long operation
  result = command("slow-command")

  @pB.say("Completed!")
  @pR.say(result)
end
```

### 4. Use Shellwords for Safety

```ruby
require 'shellwords'

escaped = Shellwords.escape(@selected)
command("program #{escaped}")
```

### 5. Respect Image Display

```ruby
def text_display_handler
  # Clear image before showing text
  clear_image

  @pR.say("Your text content")
end
```

## Debugging Plugins

### Test in Ruby Mode

1. Press `@` to enter Ruby mode
2. Test your code:
   ```ruby
   my_handler(nil)
   ```
3. Check for errors in right pane

### Reload Plugins

```ruby
# In Ruby mode
load '~/.rtfm/plugins/keys.rb'
```

Or restart RTFM.

### Check Variables

```ruby
# In Ruby mode
puts KEYMAP.keys.sort
puts @selected
puts defined?(my_handler)
```

## Plugin Ideas

### Workflow Automation

- Git workflow shortcuts
- Deployment scripts
- Backup automation
- File organization rules

### File Processing

- Batch image conversion
- Document generation
- Log analysis
- Data extraction

### Integration

- Integration with other tools
- API calls
- Database queries
- Cloud storage sync

### Information Display

- Custom file info
- Directory statistics
- Metadata extraction
- Health checks

## Sharing Plugins

Consider sharing useful plugins:
1. Post as GitHub gist
2. Share in RTFM issues/discussions
3. Create plugin collection repository

## Plugin Template

```ruby
# ~/.rtfm/plugins/keys.rb
#
# Plugin: [Name]
# Description: [What it does]
# Author: [Your name]
# Dependencies: [Required programs]

KEYMAP['[KEY]'] = :plugin_name

def plugin_name(_chr)
  # Check prerequisites
  return @pB.say("Error: dependency missing") unless cmd?('program')

  # Get input if needed
  input = @pCmd.ask('Prompt: ', 'default')
  return if input.strip.empty?

  # Show progress
  @pB.say("Processing...")

  # Do work
  begin
    result = command("your-command #{Shellwords.escape(input)}")

    # Display result
    @pR.say(result)
    @pB.say("Completed!")

  rescue => e
    @pB.say("Error: #{e.message}")
  end
end
```

## Reference

### All Available Methods

```ruby
# Command execution
command(cmd, timeout: 5, return_both: false)
shell(cmd, background: false, err: nil)
shellexec(cmd, timeout: 10)

# Utilities
cmd?(program)                    # Check if program exists
dirlist(left: false)            # Get directory listing
mark_latest                      # Update directory marks
track_file_access(path)         # Track file access
track_directory_access(path)    # Track directory access

# Display
refresh                          # Refresh layout
render                           # Render all panes
clear_image                      # Clear displayed image
showimage(path)                  # Display image

# Operations
add_undo_operation(info)        # Add to undo history
copy_to_clipboard(text, 'primary' or 'clipboard')
```

### Global Variables

```ruby
# File system
Dir.pwd                # Current directory
@selected              # Selected item path
@files                 # Current dir file list
@tagged                # Tagged items array

# Configuration
@preview               # Preview enabled?
@showimage             # Images enabled?
@trash                 # Trash enabled?
@lsall / @lslong / @lsorder / @lsinvert

# State
@index                 # Selected item index
@marks                 # Bookmarks hash
@history               # Command history array
@remote_mode           # In SSH mode?

# Display
@w / @h               # Terminal dimensions
@pL / @pR / @pT / @pB # Panes
```

---

[← Keyboard Reference](keyboard-reference.md) | [Back to README](../README.md)
