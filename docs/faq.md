# RTFM Frequently Asked Questions

Quick answers to common questions.

## General

### What does RTFM stand for?

**Ruby Terminal File Manager**

(Not the other thing... well, maybe also that if you need to Read The Fine Manual!)

### Is RTFM better than ranger?

**Different, not better.**

- **RTFM**: More features, SSH browsing, undo system, AI integration, trash bin
- **Ranger**: More mature, better documentation, larger community, cleaner design

Choose based on your needs. See [RTFM vs Ranger comparison](../README.md#rtfm-vs-ranger).

### Can I use RTFM on Windows?

**Limited support.**

Core functionality works on Windows, but:
- ✗ No image display
- ✗ No w3m/xdotool features
- ✓ File operations work
- ✓ Remote SSH works

**Recommended:** Use WSL (Windows Subsystem for Linux) for full features.

### Does RTFM work on macOS?

**Yes!** Fully supported.

Install with:
```bash
brew install ruby imagemagick w3m bat pandoc
gem install rtfm-filemanager
```

### What terminals work best?

**Best image support:**
- urxvt (w3m protocol) - Perfect
- xterm (Sixel protocol) - Perfect
- mlterm (Sixel protocol) - Perfect
- Eterm (w3m protocol) - Perfect

**Good:**
- kitty (w3m with brief flash)
- foot (Sixel)
- alacritty (no persistent images)

## Installation & Setup

### Do I need to install dependencies manually?

**Core:** No, gems auto-install (rcurses, termpix)

**Optional features:** Yes, install as needed:
- ImageMagick (images)
- bat (syntax highlighting)
- pandoc (markdown)
- fzf (fuzzy find)

See [Installation Guide](getting-started.md#installation).

### How do I update RTFM?

```bash
gem update rtfm-filemanager
```

This also updates dependencies (rcurses, termpix).

### Can I install from source?

**Yes:**
```bash
git clone https://github.com/isene/RTFM
cd RTFM
gem install rcurses termpix
sudo cp bin/rtfm /usr/bin/
```

### Where are config files stored?

```
~/.rtfm/
├── conf              # Main configuration
├── trash/            # Deleted items (if trash enabled)
├── bootsnap-cache/   # Performance cache
└── plugins/
    ├── preview.rb    # Custom preview handlers
    └── keys.rb       # Custom key bindings
```

## Features

### How do I enable the trash bin?

**In RTFM:** Press `Ctrl-d` to toggle

**In config:**
```ruby
# ~/.rtfm/conf
@trash = true
```

**Restore deleted items:** Press `U` (undo)

**Empty trash:** Press `D`

### Can I undo file operations?

**Yes!** Press `U` to undo:
- Delete (from trash)
- Move
- Rename
- Copy
- Symlink
- Bulk rename
- Permission changes
- Ownership changes

**Cannot undo:**
- Permanent deletion (trash disabled)
- Failed operations

### How do I use the AI features?

**Setup:**
1. Get OpenAI API key: https://platform.openai.com/api-keys
2. Add to config:
   ```ruby
   @ai = "sk-your-api-key-here"
   ```
3. Install gem: `gem install ruby-openai`

**Usage:**
- Press `I` on file for AI description
- Press `Ctrl-a` for AI chat

### Does RTFM support tabs?

**Yes!** Enhanced tab system:
- `]` - New tab
- `[` - Close tab
- `J/K` - Switch tabs
- `}` - Duplicate tab
- `{` - Rename tab
- `1-9` - Jump to tab number

### Can I browse remote servers?

**Absolutely!** Press `Ctrl-e`:

```
user@server.com:/path/to/directory
```

Then:
- `d` - Download files
- `u` - Upload files
- `s` - Open SSH shell

See [Remote Browsing Guide](remote-browsing.md).

### How do I copy images to clipboard?

**Press `Ctrl-y` when viewing an image.**

Then paste into:
- GIMP
- Inkscape
- Image editors
- Browsers

Works with PNG, JPEG, GIF, BMP, WebP.

### Can I customize key bindings?

**Yes!** Edit `~/.rtfm/plugins/keys.rb`:

```ruby
KEYMAP['X'] = :my_custom_action

def my_custom_action(_chr)
  @pB.say("Custom action!")
end
```

See [Plugin Guide](plugins.md).

## Usage

### How do I exit to current directory?

**Use the `r` command** (set up automatically on first run).

Workflow:
```bash
r              # Launch RTFM
# Navigate to ~/Documents/projects
q              # Quit
pwd            # Now in ~/Documents/projects
```

### How do I copy multiple files?

1. Tag files: Press `t` on each file
2. Navigate to destination
3. Press `p` to copy

**Or:** Tag with pattern:
- `Ctrl-t` then `*.txt` (tag all .txt files)

### How do I rename multiple files?

1. Tag files with `t`
2. Press `E` (bulk rename)
3. Enter pattern:
   - `s/old/new/` - Replace text
   - `PREFIX_#` - Add prefix with numbers
   - `upper` / `lower` - Change case

### How do I change permissions on multiple files?

1. Tag files with `t`
2. Press `Ctrl-p`
3. Enter permissions:
   - `755`
   - `rwxr-xr-x`
   - `+x` (add execute)
   - `-w` (remove write)

**v7.2+ Note:** Only tagged files affected (not selected unless tagged)

### What's the difference between `p` and `P`?

- `p` - **Copy** tagged items (original stays)
- `P` - **Move** tagged items (original removed)

Both preserve selection after operation (v7.2+).

### How do I preview without opening?

Files auto-preview in right pane when selected.

**Toggle preview:** Press `-`

**Scroll preview:**
- `Shift-↓/↑` - Line by line
- `TAB` - Page down
- `Shift-TAB` - Page up

### Can I execute shell commands?

**Yes!** Press `:` then enter command:
```
:ls -la
:git status
:grep -r pattern .
```

Output shows in right pane.

**History:** Press `;` to see command history

## Comparison Questions

### RTFM vs ranger?

**RTFM advantages:**
- SSH/SFTP browsing built-in
- Comprehensive undo system
- Trash bin with restore
- OpenAI integration
- Permission/ownership undo
- Smaller codebase

**Ranger advantages:**
- Larger community
- Better documentation (working on it!)
- More mature/stable
- Multi-column view

### RTFM vs mc (Midnight Commander)?

**RTFM advantages:**
- Modern design
- Better image support
- Git integration
- AI features
- Undo system

**mc advantages:**
- More established (since 1994)
- Built-in editor (mcedit)
- FTP support
- Virtual file systems

### Why not use GUI file manager?

**Benefits of terminal file managers:**
- ⚡ Faster (keyboard-driven)
- 🖥️ Works over SSH
- 🎯 Precision control
- 🔧 Scriptable/extensible
- 💻 No X server needed
- ⌨️ Never leave terminal

**RTFM specifically:**
- Parses LS_COLORS (consistent theming)
- Inline images
- Command execution with output
- Ruby extensibility

## Technical Questions

### What is rcurses?

**rcurses** is a pure Ruby curses library created specifically for RTFM.

- No C bindings
- Ruby 3.4+ compatible
- Modern design
- Easy to maintain

See: https://github.com/isene/rcurses

### What is termpix?

**termpix** is a terminal image display library extracted from RTFM.

- Multi-protocol support (Sixel, w3m)
- EXIF auto-orient
- Used by RTFM, AstroPanel, IMDB

See: https://github.com/isene/termpix

### Why single-file architecture?

**Benefits:**
- Easy to understand (all code in one place)
- Simple deployment (one file)
- No require complexity
- Easier debugging

**Trade-offs:**
- Large file (~6K lines)
- Not modular
- But: Organized with vim folds

### Can I contribute?

**Yes!**

- Bug reports: https://github.com/isene/RTFM/issues
- Feature requests: Open issue with detailed description
- Pull requests: Welcome!
- Plugins: Share in issues/discussions

### Is RTFM actively maintained?

**Yes!** Regular updates and releases.

Recent activity:
- v7.3 (Nov 2025) - Image display improvements
- v7.2 (Oct 2025) - Batch operation consistency
- v7.1 (Oct 2025) - Archive preview

Check: https://github.com/isene/RTFM/releases

## Workflow Questions

### Best workflow for organizing photos?

```
r                    # Launch RTFM
@lsorder = "-t"     # Sort by time (newest first)
@showimage = true   # Show images
# Tag keepers with 't'
P                   # Move to organized folder
```

### Best workflow for code projects?

```
r                # Launch
m p             # Bookmark project directory
@batuse = true  # Syntax highlighting
@lsall = "-a"   # Show hidden (.git, etc.)
G               # Check git status
```

### How to quickly check server logs?

```
r
Ctrl-e                        # Remote mode
admin@server:/var/log        # Connect
# Navigate to log file
# Content shows in right pane
s                             # Open shell if needed
```

### Bulk file organization?

```
r
Ctrl-t           # Tag by pattern
*.jpg           # Tag all JPEGs
P               # Move to new folder
```

## Still Have Questions?

1. **Check documentation:**
   - `man rtfm`
   - Press `?` in RTFM
   - Read [guides](../README.md#documentation)

2. **Search issues:**
   https://github.com/isene/RTFM/issues

3. **Ask:**
   - Open new issue
   - Email: g@isene.com

---

[← Troubleshooting](troubleshooting.md) | [Back to README](../README.md)
