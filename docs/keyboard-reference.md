# RTFM Keyboard Reference

Complete keyboard shortcut reference organized by category.

**Quick access:** Press `?` in RTFM for built-in help.

## Basic Keys

| Key | Action |
|-----|--------|
| `?` | Show help text |
| `v` | Show version and image protocol |
| `r` | Refresh display (terminal resize) |
| `R` | Reload configuration |
| `W` | Write config to ~/.rtfm/conf |
| `C` | Show current configuration |
| `q` | Quit and save |
| `Q` | Quit without saving |

## Navigation

### Basic Movement

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down one item |
| `k` / `↑` | Move up one item |
| `h` / `←` | Go to parent directory |
| `l` / `→` / `ENTER` | Enter directory or open file |
| `HOME` | Jump to first item |
| `END` | Jump to last item |
| `PgDn` | Page down |
| `PgUp` | Page up |

### Directory Navigation

| Key | Action |
|-----|--------|
| `~` | Jump to home directory |
| `'` + letter | Jump to bookmark |
| `>` | Follow symlink to target |
| `Ctrl-r` | Show recent files/directories |

## Marks & Bookmarks

| Key | Action |
|-----|--------|
| `m` + letter | Set bookmark (a-z) |
| `m` + `-` + letter | Delete bookmark |
| `M` | Show all bookmarks |
| `'` + letter | Jump to bookmark |

**Special bookmarks:**
- `'` - Last visited directory
- `0` - Launch directory
- `1-5` - Last 5 visited (auto-managed)

## Tagging

| Key | Action |
|-----|--------|
| `t` | Tag/untag current item |
| `Ctrl-t` | Tag items matching pattern |
| `T` | Show tagged items list |
| `u` | Untag all items |

**Pattern examples:**
- `.` - Tag all items
- `*.txt` - Tag all .txt files
- `test.*` - Tag files starting with "test"

## File Operations

### Copy & Move

| Key | Action |
|-----|--------|
| `p` | Copy tagged items here |
| `P` | Move tagged items here |
| `s` | Create symlinks to tagged items |

### Rename

| Key | Action |
|-----|--------|
| `c` | Rename single item |
| `E` | Bulk rename tagged items (patterns) |

**Bulk rename patterns:**
- `s/old/new/` - Replace text
- `PREFIX_#` - Add prefix with counter
- `upper` / `lower` - Change case

### Delete

| Key | Action |
|-----|--------|
| `d` | Delete (trash if enabled) |
| `D` | Empty trash directory |
| `Ctrl-d` | Toggle trash on/off |
| `U` | Undo last operation |

**Undo works for:**
- Delete (from trash)
- Move
- Rename
- Copy
- Symlink
- Bulk rename
- Permissions
- Ownership

## Permissions & Ownership

| Key | Action |
|-----|--------|
| `Ctrl-p` | Change permissions |
| `Ctrl-o` | Change ownership (user:group) |

### Permission Formats

| Format | Example | Description |
|--------|---------|-------------|
| Octal | `755` | rwxr-xr-x |
| Full | `rwxr-xr-x` | Explicit permissions |
| Short | `rwx` | Apply to all (user, group, other) |
| Add | `+x` | Add execute for all |
| Remove | `-w` | Remove write for all |
| Combined | `+rw` | Add read and write |

## Search & Filter

### Filtering

| Key | Action |
|-----|--------|
| `f` | Filter by extension |
| `F` | Filter by regex pattern |
| `Ctrl-f` | Clear all filters |

**Examples:**
- `f` → `txt` - Show only .txt files
- `f` → `pdf,png,jpg` - Show PDFs and images
- `F` → `test.*\.rb` - Show test*.rb files

### Searching

| Key | Action |
|-----|--------|
| `/` | Search and highlight |
| `n` | Next match |
| `N` | Previous match |
| `\` | Clear search |

### Finding Files

| Key | Action |
|-----|--------|
| `g` | Grep content in files |
| `L` | Locate files (then `#` to jump) |
| `Ctrl-l` | Fuzzy find with fzf |

## Display Options

### Layout

| Key | Action |
|-----|--------|
| `w` | Change pane width ratio |
| `B` | Cycle border styles |
| `-` | Toggle preview on/off |
| `_` | Toggle image preview |
| `b` | Toggle syntax highlighting |

**Pane widths:**
- 2 = Narrow left (20%)
- 5 = Balanced (50%) - default
- 7 = Wide left (70%)

**Border styles:**
- 0 = No borders
- 1 = Right pane only
- 2 = Both panes
- 3 = Left pane only

### File List Options

| Key | Action |
|-----|--------|
| `a` | Show/hide hidden files |
| `A` | Toggle long info (ls -l) |
| `o` | Change sort order |
| `i` | Invert sort order |
| `O` | Show current sort command |

**Sort orders (cycle with `o`):**
- Name
- Size
- Time
- Extension

## Right Pane Controls

| Key | Action |
|-----|--------|
| `ENTER` | Refresh right pane |
| `Shift-↓` | Scroll down one line |
| `Shift-↑` | Scroll up one line |
| `TAB` / `Shift-→` | Page down |
| `Shift-TAB` / `Shift-←` | Page up |

## Clipboard Operations

| Key | Action |
|-----|--------|
| `y` | Copy path → primary selection (middle-click paste) |
| `Y` | Copy path → clipboard (Ctrl-v paste) |
| `Ctrl-y` | Copy image to clipboard (or right pane text) |

**Image clipboard:**
When viewing an image, `Ctrl-y` copies the actual image file - paste into GIMP, Inkscape, etc.

## Tab Management

| Key | Action |
|-----|--------|
| `]` | Create new tab (current directory) |
| `[` | Close current tab |
| `J` | Previous tab |
| `K` | Next tab |
| `}` | Duplicate current tab |
| `{` | Rename current tab |
| `1-9` | Switch to tab number |

**Tab indicator:** Top-right shows `[2/5]` (tab 2 of 5)

## Archives

| Key | Action |
|-----|--------|
| `z` | Extract tagged archive |
| `Z` | Create archive from tagged items |

**Supported formats:** .zip, .tar, .gz, .bz2, .xz, .rar, .7z

## Git Operations

| Key | Action |
|-----|--------|
| `G` | Show git status for current directory |
| `H` | Cryptographic hash of directory tree |

**Hash feature:**
- First run: Creates hash
- Subsequent runs: Compares and reports changes

## OpenAI Integration

| Key | Action |
|-----|--------|
| `I` | Get AI description of file |
| `Ctrl-a` | Start AI chat session |

**Requirements:**
- `ruby-openai` gem installed
- API key in config: `@ai = "sk-..."`

**Chat features:**
- Persistent context during RTFM session
- Specialized for file/directory questions
- Press ESC to exit chat

## System Operations

| Key | Action |
|-----|--------|
| `S` | Show comprehensive system info |
| `e` | Show detailed file properties |
| `=` | Create new directory |
| `X` | Compare two tagged files |
| `Ctrl-n` | Invoke navi cheatsheet tool |

## Command Mode

| Key | Action |
|-----|--------|
| `:` | Enter command mode |
| `;` | Show command history |
| `@` | Enter Ruby debug mode |
| `+` | Add program to interactive whitelist |

### Command Mode Features

**Execute commands:**
```
:ls -la
:git status
:grep -r pattern .
```

**Force interactive mode:**
```
:§htop        # Full-screen htop
:§vim file    # Full-screen vim
```

**Output:** Displayed in right pane

## Ruby Debug Mode

Press `@` to enter Ruby REPL:

```ruby
# Inspect variables
puts @selected
puts @tagged.inspect
puts @marks

# Execute Ruby code
Dir.pwd
@files.size
```

Useful for plugin development and debugging.

## Remote Mode Keys

(Only active when in remote mode - press `Ctrl-e`)

| Key | Action |
|-----|--------|
| `Ctrl-e` | Toggle remote mode |
| `↑` `↓` | Navigate files |
| `←` `h` | Parent directory |
| `→` `ENTER` | Show file info |
| `d` | Download file |
| `u` | Upload tagged files |
| `s` | Open SSH shell |

## Special Key Combinations

### Multi-Key Sequences

| Sequence | Action |
|----------|--------|
| `m` → letter | Set bookmark |
| `'` → letter | Jump to bookmark |
| `m` → `-` → letter | Delete bookmark |
| `Ctrl-t` → pattern | Tag by pattern |

### Contextual Keys

Some keys behave differently based on context:

**`d` key:**
- Local mode: Delete
- Remote mode: Download

**`→` key:**
- On directory: Enter directory
- On file: Open file
- Remote mode: Show file info

**`Ctrl-y` key:**
- On image: Copy image to clipboard
- On text: Copy right pane text

## Quick Reference Card

![Keyboard cheat sheet](../img/rtfm-kb.png)

## Customization

All keys can be remapped in `~/.rtfm/plugins/keys.rb`

Example:
```ruby
# Swap j and k
KEYMAP['j'] = :move_up
KEYMAP['k'] = :move_down
```

See [Plugins Guide](plugins.md) for details.

---

[← Remote Browsing](remote-browsing.md) | [Next: Plugins →](plugins.md)
