# RTFM Configuration Guide

Complete guide to customizing RTFM.

## Configuration File

Location: `~/.rtfm/conf`

RTFM automatically creates this file on first exit, saving:
- Bookmarks (@marks)
- Tagged items
- Command history
- Directory hashes

## Viewing Configuration

| Action | Key |
|--------|-----|
| View current config | `C` |
| Save config | `W` |
| Reload config | `R` |

## Core Settings

### Display Options

```ruby
# Toggle preview in right pane
@preview = true          # false to disable

# Toggle image display
@showimage = true        # false to disable

# Show hidden files
@lsall = "-a"           # "" to hide hidden files

# Show long file info (ls -l format)
@lslong = true          # false for compact view

# Pane width ratio (2-7)
# 2 = narrow left, 7 = wide left
@width = 5

# Border style (0-3)
# 0 = no borders
# 1 = right pane only
# 2 = both panes
# 3 = left pane only
@border = 2

# Syntax highlighting
@batuse = true          # false to use plain cat
```

### File Operations

```ruby
# Enable trash bin (move to ~/.rtfm/trash instead of permanent delete)
@trash = true           # false for permanent deletion

# Use run-mailcap instead of xdg-open
@runmailcap = true      # false to use xdg-open
```

### Sorting & Ordering

```ruby
# Sort order
@lsorder = ""           # "" = name
                        # "-S" = size
                        # "-t" = time
                        # "-X" = extension

# Invert sort
@lsinvert = ""          # "-r" to reverse

# Additional ls options
@lsuser = "--ignore=test"   # Any valid ls flags
```

### File Type Filtering

```ruby
# Show only specific extensions
@lsfiles = "txt,md,rb"      # Comma-separated extensions
                            # "" to show all
```

## Color Customization

### Pane Colors

```ruby
# Bottom pane background
@bottomcolor = 238

# Command mode background
@cmdcolor = 24

# Ruby debug mode background
@rubycolor = 52

# OpenAI chat background
@aicolor = 17
```

### Path-Based Top Bar Colors

Change top bar color based on current path:

```ruby
@topmatch = [
  ["projects", 165],      # Blue when path contains "projects"
  ["downloads", 220],     # Yellow for downloads
  ["personal", 156],      # Green for personal
  ["", 238]               # Default gray
]
```

**Order matters:** First match wins. Last entry should have empty string for default.

## Persistent Data

### Bookmarks

```ruby
# Directory bookmarks (saved automatically)
@marks = {
  "h" => "/home/user",
  "d" => "/home/user/Documents",
  "p" => "/home/user/projects",
  "0" => "/initial/launch/directory"
}
```

**Special marks:**
- `'` - Last visited directory
- `0` - Launch directory
- `1-5` - Last 5 visited directories (auto-managed)

### Command History

```ruby
# Prepopulate command history
@history = [
  "git status",
  "ls -la",
  "cat TODO.txt"
]
```

### Ruby Command History

```ruby
# Prepopulate Ruby debug history
@rubyhistory = [
  "puts @selected",
  "puts @tagged.inspect"
]
```

### OpenAI History

```ruby
# Prepopulate AI chat history
@aihistory = [
  "Explain this code",
  "What does this file do?"
]
```

### SSH Connection History

```ruby
# Prepopulate SSH connections
@sshhistory = [
  "user@server.com:/var/www # Production",
  "admin@192.168.1.10 # Local dev"
]
```

### Directory Hashes

```ruby
# Cryptographic hashes of directory trees
# (generated with H key, compared on subsequent runs)
@hash = {
  "/home/user/important" => "abc123...",
  "/etc/config" => "def456..."
}
```

## Advanced Settings

### Interactive Program Whitelist

Programs that take full terminal control must be whitelisted:

```ruby
@interactive = "htop,vim,emacs,nano,less,ranger,mc"
```

**Add programs:**
- Press `+` in RTFM and type program name
- Or manually add to @interactive

**Force interactive mode:**
- Prefix command with `§`: `:§program`

### OpenAI Integration

```ruby
# Add your OpenAI API key
@ai = "sk-your-api-key-here"
```

**Features enabled:**
- `I` - Get file description
- `Ctrl-a` - Start AI chat

**Get API key:** https://platform.openai.com/api-keys

### Preview Customization

See [plugins.md](plugins.md) for custom preview handlers.

## Configuration Best Practices

### Organized Config File

```ruby
# ~/.rtfm/conf - Well organized

# ============================================================
# DISPLAY SETTINGS
# ============================================================
@preview     = true
@showimage   = true
@batuse      = true
@width       = 5
@border      = 2

# ============================================================
# FILE OPERATIONS
# ============================================================
@trash       = true
@runmailcap  = false

# ============================================================
# SORTING
# ============================================================
@lsall       = "-a"
@lslong      = false
@lsorder     = ""
@lsinvert    = ""

# ============================================================
# COLORS
# ============================================================
@bottomcolor = 238
@cmdcolor    = 24
@aicolor     = 17

@topmatch = [
  ["work", 165],
  ["personal", 156],
  ["", 238]
]

# ============================================================
# BOOKMARKS (auto-managed, but you can edit)
# ============================================================
@marks = {
  "h" => ENV['HOME'],
  "d" => "#{ENV['HOME']}/Documents",
  "w" => "#{ENV['HOME']}/work"
}

# ============================================================
# HISTORY (auto-managed)
# ============================================================
@history = []
@rubyhistory = []
@aihistory = []
@sshhistory = []

# ============================================================
# ADVANCED
# ============================================================
@interactive = "htop,vim,nano,emacs,ranger"
@ai = ""  # Add your OpenAI key here
```

### Testing Changes

After editing `~/.rtfm/conf`:
1. Press `R` in RTFM to reload
2. Or restart RTFM

### Backing Up Config

```bash
cp ~/.rtfm/conf ~/.rtfm/conf.backup
```

## Terminal-Specific Settings

### urxvt / xterm / Eterm

No special configuration needed - works perfectly out of the box.

### kitty

Images work with brief flash (w3m protocol limitation with kitty).

### mlterm

Best Sixel protocol support - fast inline images.

## Resetting Configuration

```bash
# Backup current config
cp ~/.rtfm/conf ~/.rtfm/conf.old

# Delete config (will regenerate on next run)
rm ~/.rtfm/conf

# Or reset specific settings
r                # Launch RTFM
W                # Write default config
```

## Environment Variables

RTFM respects standard environment variables:

```bash
# Default editor
export EDITOR=vim

# LS_COLORS for terminal theming
export LS_COLORS="di=1;34:ln=1;36:..."

# OpenAI key (alternative to @ai in config)
export OPENAI_API_KEY="sk-..."
```

## Performance Tuning

### For Large Directories

```ruby
# Turn off preview for faster navigation
@preview = false

# Turn off long info
@lslong = false

# Disable images
@showimage = false
```

### For Slow Networks (SSH)

Enable persistent SSH connections in `~/.ssh/config`:
```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
```

## Troubleshooting

### Config File Errors

If RTFM won't start after editing config:

```bash
# Check for syntax errors
ruby -c ~/.rtfm/conf

# Restore backup
cp ~/.rtfm/conf.backup ~/.rtfm/conf
```

### Reset to Defaults

```bash
mv ~/.rtfm ~/.rtfm.old
# Restart RTFM - creates fresh config
```

---

[← Getting Started](getting-started.md) | [Next: Keyboard Reference →](keyboard-reference.md)
