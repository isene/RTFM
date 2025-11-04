# Getting Started with RTFM

This guide will get you up and running with RTFM in minutes.

## Installation

### Quick Install (Recommended)

```bash
gem install rtfm-filemanager
```

### With Full Features (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install ruby-full x11-utils xdotool bat pandoc poppler-utils \
  odt2txt docx2txt unzip gnumeric catdoc w3m imagemagick \
  ffmpegthumbnailer tar gzip bzip2 xz-utils unrar p7zip-full

gem install rtfm-filemanager
```

### macOS

```bash
brew install ruby imagemagick w3m bat pandoc poppler
gem install rtfm-filemanager
```

## First Launch

```bash
rtfm
```

On first run, RTFM will:
1. Show a welcome message
2. Add `r` function to your shell config (~/.bashrc or ~/.zshrc)
3. Create `~/.rtfm/` directory with plugins and config

Press `q` to accept and continue.

## The `r` Command

After installation, you can launch RTFM with just:

```bash
r
```

The magic: When you quit RTFM (press `q`), you'll be in RTFM's current directory, not where you launched it.

**Example workflow:**
```bash
r                    # Launch RTFM
# Navigate to ~/Documents/projects
q                    # Quit RTFM
pwd                  # You're in ~/Documents/projects
r                    # Launch RTFM again (remembers location)
```

## Basic Navigation

### Moving Around

| Key | Action |
|-----|--------|
| `↓` or `j` | Move down |
| `↑` or `k` | Move up |
| `→` or `l` or `ENTER` | Enter directory / open file |
| `←` or `h` | Go to parent directory |
| `HOME` | Jump to first item |
| `END` | Jump to last item |
| `PgDn` | Page down |
| `PgUp` | Page up |

### Understanding the Interface

```
┌─────────────────────────────────────────────────────────┐
│ Path: /home/user/Documents (drwxr-xr-x...) [Tab: 1/3]  │ ← Top bar (path + metadata)
├──────────────┬──────────────────────────────────────────┤
│ projects/    │ # My Projects                            │
│ photos/      │                                          │
│ > notes.txt  │ This is the content of notes.txt         │ ← Right pane (preview)
│ todo.md      │ shown with syntax highlighting...        │
│ report.pdf   │                                          │
│              │                                          │
└──────────────┴──────────────────────────────────────────┘
│ Status: 5 items                                         │ ← Bottom bar (status)
└─────────────────────────────────────────────────────────┘
  Left pane ↑        Right pane ↑
  (navigate)         (preview)
```

## Essential Operations

### Viewing Files

- **Preview**: Content shows in right pane automatically
- **Open in editor**: Press `ENTER` on text files
- **Open with default app**: Press `x` on files (xdg-open)
- **Toggle preview**: Press `-` to turn preview on/off
- **Toggle images**: Press `_` to toggle image display

### Working with Files

#### Copy
1. Tag files with `t` (toggle tag on/off)
2. Navigate to destination directory
3. Press `p` to copy tagged items

#### Move
1. Tag files with `t`
2. Navigate to destination
3. Press `P` to move tagged items

#### Delete
1. Press `d` on item (or tag multiple with `t` first)
2. Press `y` to confirm

**Trash bin:** Press `Ctrl-d` to enable trash bin. Deleted items go to `~/.rtfm/trash/` and can be restored with `U` (undo).

#### Rename
- **Single file**: Press `c`, edit name, press ENTER
- **Bulk rename**: Tag files with `t`, press `E`, use pattern

### Bookmarks

**Set bookmark:**
1. Navigate to directory
2. Press `m`
3. Press letter (a-z)

**Jump to bookmark:**
1. Press `'` (apostrophe)
2. Press bookmark letter

**Special bookmarks:**
- `'` - Last directory (for quick toggling)
- `0` - Directory where RTFM started
- `1-5` - Last 5 visited directories

## Getting Help

### In RTFM

Press `?` to show complete keyboard reference

### Man Page

```bash
man rtfm
```

### Version Info

Press `v` to see:
- RTFM version
- Image protocol in use
- Latest available version

## Common Tasks

### Browse Directory Tree

```bash
r                # Launch RTFM
h h h           # Go up 3 levels
' h             # Jump to home bookmark
l               # Enter directory
```

### Find and Open File

```bash
r                # Launch
/pattern        # Search for pattern
n               # Next match
ENTER           # Open file
```

### Copy Files Between Directories

```bash
r                # Launch
m s             # Bookmark source as 's'
' s             # Jump to source
t t t           # Tag 3 files
m d             # Bookmark destination as 'd'
' d             # Jump to destination
p               # Copy tagged files here
```

### Remote File Management

```bash
r                          # Launch
Ctrl-e                     # Enter remote mode
user@server.com:/path     # Enter connection
# Navigate with arrow keys
d                          # Download file
Ctrl-e                     # Exit remote mode
```

## Tips & Tricks

### Speed Tips

1. **Turn off preview** (`-`) for faster directory traversal
2. **Use bookmarks** (`m` + letter) for frequent locations
3. **Use tabs** (`]` to create) for multi-directory work
4. **Recent files** (`Ctrl-r`) to jump to recently accessed files

### Power User Tips

1. **Undo system** - `U` undoes: delete, move, rename, copy, symlink, permissions, ownership
2. **Pattern rename** - `E` for bulk rename with regex
3. **Command mode** - `:` to run any shell command, output in right pane
4. **Ruby mode** - `@` to execute Ruby code (for debugging or scripting)
5. **Git workflow** - `G` shows git status, perfect for checking changes

### Workflow Examples

#### Photo Organization
```
r → Navigate to photos → t t t (tag) → P (move to new folder)
```

#### Code Review
```
r → / .rb (search) → G (git status) → ENTER (open in editor)
```

#### Remote Backup
```
r → Ctrl-e → server:/backup → u (upload tagged files)
```

## Next Steps

- Read [Configuration Guide](configuration.md) to customize RTFM
- Learn [Remote Browsing](remote-browsing.md) for SSH workflows
- Explore [Plugins](plugins.md) to extend functionality
- Check [Keyboard Reference](keyboard-reference.md) for all keys

## Troubleshooting

### Images Don't Show

1. Check if w3m is installed: `which w3mimgdisplay`
2. Check if xdotool is installed: `which xdotool`
3. Press `v` to see image protocol (should show `w3m` or `sixel`)
4. Try toggling image preview: `_`

### Commands Don't Work in Command Mode

Some commands need to be whitelisted as "interactive":
1. Press `+` in RTFM
2. Type program name (e.g., `htop`)
3. Or prefix command with `§`: `:§htop`

### Terminal Resize Issues

Press `r` to manually refresh RTFM layout

### General Issues

1. Press `r` to refresh
2. Check `~/.rtfm/conf` for misconfigurations
3. Report bugs: https://github.com/isene/RTFM/issues

---

[← Back to README](../README.md) | [Next: Configuration →](configuration.md)
