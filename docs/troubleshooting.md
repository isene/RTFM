# RTFM Troubleshooting Guide

Solutions to common issues and problems.

## Installation Issues

### Gem Install Fails

**Problem:** `gem install rtfm-filemanager` fails with permission error

**Solution:**
```bash
# Use --user-install
gem install --user-install rtfm-filemanager

# Or use sudo (system-wide)
sudo gem install rtfm-filemanager
```

### Missing Dependencies

**Problem:** Error about missing rcurses or termpix

**Solution:**
```bash
gem install rcurses termpix
# Then retry
gem install rtfm-filemanager
```

### Ruby Version Too Old

**Problem:** RTFM requires Ruby 2.7+

**Solution:**
```bash
# Check Ruby version
ruby --version

# Update Ruby (Ubuntu)
sudo apt install ruby-full

# Update Ruby (ArchLinux)
sudo pacman -Syu ruby

# Update Ruby (macOS)
brew install ruby

# Or use rbenv/rvm/asdf for version management
```

## Display Issues

### Terminal Shows Garbage Characters

**Problem:** Escape sequences or weird characters

**Solution:**
1. Press `r` to refresh
2. Check terminal supports 256 colors: `echo $TERM`
3. Try different terminal (urxvt, xterm, mlterm recommended)

### Screen Doesn't Resize Properly

**Problem:** RTFM doesn't adapt to terminal resize

**Solution:**
- Press `r` to manually refresh layout
- Works automatically in most terminals
- i3-wm users: Should work automatically now (v7.1.4+)

### Borders Look Wrong

**Problem:** Borders appear broken or as letters

**Solution:**
1. Terminal doesn't support Unicode box drawing
2. Press `B` to cycle border styles
3. Press `B` until you get `0` (no borders)

### Colors Look Wrong

**Problem:** Colors don't match terminal theme

**Solution:**
RTFM parses LS_COLORS automatically. Check your LS_COLORS:
```bash
echo $LS_COLORS
```

To customize, see: https://github.com/isene/LS_COLORS

## Image Display Issues

### Images Don't Show

**Problem:** No images displayed in terminal

**Solution:**
1. Check if image preview is on: Press `_` to toggle
2. Check if preview is on: Press `-` to toggle
3. Press `v` to see detected image protocol
4. Verify dependencies:
   ```bash
   which identify        # ImageMagick
   which w3mimgdisplay  # w3m
   which xdotool        # For image redraw
   ```
5. Install missing dependencies:
   ```bash
   sudo apt install imagemagick w3m-img xdotool
   ```

### Images Flash/Flicker

**Problem:** Images appear briefly then disappear

**Terminal:** This is normal in kitty terminal (w3m protocol limitation)

**Solution:**
- Use urxvt, xterm, or mlterm for better experience
- Or accept the brief flash (images still work)

### Images Overlap or Leave Residue

**Problem:** Old images don't clear properly

**Solution:**
1. Press `r` to refresh
2. Update to RTFM 7.3+ (automatic clearing)
3. Check termpix version: Should be 0.2+

### Images Show Rotated Incorrectly

**Problem:** Phone photos display sideways

**Solution:**
Update termpix to 0.2+ (EXIF auto-orient support):
```bash
gem update termpix
```

### Images Stretched/Distorted

**Problem:** Images don't maintain aspect ratio

**Solution:**
Update to termpix 0.2.1+ (aspect ratio fixes):
```bash
gem update termpix
```

## Performance Issues

### Slow Navigation in Image Directories

**Problem:** First pass through image directory is slow

**Solution:**
- Normal behavior (creating auto-orient cache)
- Second pass is fast (uses cache)
- Turn off preview for faster navigation: Press `-`
- Turn off images: Press `_`

### Slow with Large Files

**Problem:** Lag when navigating files over 100MB

**Solution:**
RTFM doesn't preview files over 1MB by default. If still slow:
1. Turn off preview: Press `-`
2. Turn off long info: Press `A`
3. Disable image metadata: Already optimized in 7.3.6+

### Keyboard Lag When Image Displayed

**Problem:** Keys respond slowly with large images

**Solution:**
Fixed in RTFM 7.3.3+. Update:
```bash
gem update rtfm-filemanager
```

Image redraw checking now only runs when idle.

## File Operation Issues

### Can't Delete Files

**Problem:** Delete doesn't work or shows error

**Solutions:**

**Check permissions:**
```bash
ls -la
```

**Trash is full:**
```bash
# In RTFM:
D  # Empty trash

# Or manually:
rm -rf ~/.rtfm/trash/*
```

**Undefined variable 'esc' error:**
- Fixed in 7.3.4+
- Update: `gem update rtfm-filemanager`

### Undo Doesn't Work

**Problem:** Press `U` but nothing happens

**Causes:**
1. No undoable operations performed yet
2. Permanent deletion (no undo)
3. Operation failed

**Check:**
- Undo only works for successful operations
- Permanent delete (trash off) cannot be undone
- Try undo immediately after operation

### Can't Open File in Editor

**Problem:** Press ENTER but file doesn't open

**Solutions:**

**Check file type:**
- Binary files open with xdg-open, not $EDITOR
- Try pressing `x` to force xdg-open

**Set $EDITOR:**
```bash
export EDITOR=vim
# Add to ~/.bashrc or ~/.zshrc
```

**UTF-16 files:**
- Update to RTFM 7.3.3+ (UTF-16 support)

### Permission Change Doesn't Update Colors

**Problem:** Changed permissions but file color doesn't change

**Solution:**
Fixed in 7.1.3+. Update:
```bash
gem update rtfm-filemanager
```

## Remote Mode Issues

### Can't Connect to Server

**Problem:** SSH connection fails

**Solutions:**

**Test SSH directly:**
```bash
ssh user@hostname
```
If this fails, fix SSH first.

**Common causes:**
- Wrong username/hostname
- SSH key not set up
- Firewall blocking port 22
- Server not running SSH

**Set up SSH key:**
```bash
ssh-keygen -t ed25519
ssh-copy-id user@hostname
```

### Slow Remote Browsing

**Problem:** Remote directory listing is slow

**Solution:**

Enable persistent SSH connections in `~/.ssh/config`:
```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
```

### Upload/Download Fails

**Problem:** File transfer doesn't work

**Solutions:**

**Check disk space:**
```bash
# On remote: Press 's' to open shell
df -h
```

**Check permissions:**
- Remote directory must be writable
- Local directory must be readable

**Large files:**
- May timeout - use rsync for files >100MB

### Remote Shell Won't Open

**Problem:** Press `s` but shell doesn't open

**Solutions:**
1. Check SSH shell access: `ssh user@host`
2. Firewall may block interactive sessions
3. Try manual: `:§ssh user@host`

## Configuration Issues

### Config File Errors

**Problem:** RTFM won't start after editing config

**Solution:**

**Check syntax:**
```bash
ruby -c ~/.rtfm/conf
```

**Common errors:**
- Missing quotes around strings
- Unmatched brackets in arrays/hashes
- Ruby syntax errors

**Restore backup:**
```bash
cp ~/.rtfm/conf.backup ~/.rtfm/conf
```

**Reset to defaults:**
```bash
mv ~/.rtfm/conf ~/.rtfm/conf.old
# Restart RTFM - creates fresh config
```

### Settings Don't Persist

**Problem:** Changes lost after restart

**Solution:**
Press `W` in RTFM to save settings to config file.

### Bookmarks Lost

**Problem:** Bookmarks disappear

**Cause:** Exited with `Q` (quit without save)

**Solution:**
- Exit with `q` (lowercase) to save
- Or press `W` before quitting

## Command Mode Issues

### Command Hangs Terminal

**Problem:** Command freezes RTFM

**Cause:** Interactive program not whitelisted

**Solutions:**

**Whitelist program:**
1. Press `+` in RTFM
2. Type program name
3. Press `W` to save

**Or prefix with §:**
```
:§htop
:§vim file
```

### Command Output Not Shown

**Problem:** Ran command but no output in right pane

**Solutions:**
- Command may have no output (try `:ls -la`)
- Command may have failed (check syntax)
- Try `shellexec` method in Ruby mode:
  ```ruby
  @
  shellexec("your-command")
  ```

## OpenAI Integration Issues

### AI Features Don't Work

**Problem:** `I` or `Ctrl-a` do nothing

**Solutions:**

**Install ruby-openai:**
```bash
gem install ruby-openai
```

**Add API key to config:**
```ruby
# ~/.rtfm/conf
@ai = "sk-your-api-key-here"
```

**Or environment variable:**
```bash
export OPENAI_API_KEY="sk-..."
```

**Get API key:**
https://platform.openai.com/api-keys

### AI Responses Slow

**Normal:** OpenAI API calls take 2-10 seconds

**If very slow:**
- Check internet connection
- API may be experiencing issues
- Try again later

## Plugin Issues

### Plugin Not Loading

**Problem:** Custom plugin doesn't work

**Solutions:**

**Check syntax:**
```bash
ruby -c ~/.rtfm/plugins/keys.rb
ruby -c ~/.rtfm/plugins/preview.rb
```

**Restart RTFM:**
Plugins load on startup only

**Test in Ruby mode:**
```ruby
@
load '~/.rtfm/plugins/keys.rb'
```

### Custom Key Doesn't Work

**Problem:** Defined key binding but nothing happens

**Check:**
1. KEYMAP assignment correct: `KEYMAP['X'] = :handler`
2. Method defined: `def handler(_chr)`
3. No syntax errors in method
4. Restart RTFM

**Debug:**
```ruby
@
puts KEYMAP['X']        # Should show :handler
puts defined?(handler)  # Should show "method"
```

## Platform-Specific Issues

### macOS: bat Command Not Found

**Problem:** Syntax highlighting doesn't work

**Solution:**
macOS uses `bat`, not `batcat`:
```ruby
# ~/.rtfm/conf
@bat = "bat"
```

Or install batcat alias:
```bash
ln -s /usr/local/bin/bat /usr/local/bin/batcat
```

### Windows: Images Don't Work

**Expected:** Image display not supported on Windows

**Solution:**
- Use WSL (Windows Subsystem for Linux)
- Or accept no image preview on Windows

### i3-wm: Terminal Resize Crashes

**Problem:** RTFM crashes when resizing in i3

**Solution:**
Fixed in 7.1.4+. Update:
```bash
gem update rtfm-filemanager
```

## General Troubleshooting

### RTFM Won't Start

**Checklist:**
1. Ruby installed: `ruby --version`
2. rcurses installed: `gem list rcurses`
3. termpix installed: `gem list termpix`
4. No config errors: `ruby -c ~/.rtfm/conf`

**Nuclear option:**
```bash
rm -rf ~/.rtfm
# Restart RTFM - fresh install
```

### Strange Behavior After Update

**Problem:** Weird issues after updating RTFM

**Solution:**
1. Update all dependencies:
   ```bash
   gem update rcurses termpix bootsnap ruby-openai
   ```
2. Clear bootsnap cache:
   ```bash
   rm -rf ~/.rtfm/bootsnap-cache
   ```
3. Restart RTFM

### Right Pane Shows Error Messages

**Problem:** Errors displayed in right pane

**Solution:**
- Read the error message (usually helpful!)
- Check if required program is installed
- Report bug if unexpected: https://github.com/isene/RTFM/issues

### Performance Degradation Over Time

**Problem:** RTFM gets slower the longer it runs

**Solutions:**
1. Press `r` to refresh
2. Clear cache: `rm -rf ~/.rtfm/bootsnap-cache`
3. Restart RTFM
4. Check if directory has many files (turn off preview)

## Getting Help

### In RTFM
- Press `?` for help
- Press `v` for version info
- Press `@` for Ruby debug mode

### Documentation
- Man page: `man rtfm`
- Docs: https://github.com/isene/RTFM/tree/main/docs
- README: https://github.com/isene/RTFM

### Community
- GitHub Issues: https://github.com/isene/RTFM/issues
- Author: g@isene.com

### Debug Information

When reporting bugs, include:
```bash
# RTFM version
rtfm --version  # Or press 'v' in RTFM

# Ruby version
ruby --version

# Gem versions
gem list rcurses termpix

# Terminal type
echo $TERM

# OS
uname -a
```

## Known Limitations

### By Design

1. **No GUI** - Terminal only
2. **Single instance** - Each RTFM runs independently
3. **Image protocols** - Kitty graphics incompatible with curses apps
4. **Remote safety** - No delete/move in remote mode (use SSH shell)
5. **File size** - Large files (>1MB) skip preview

### Workarounds

**Need to edit 100MB+ file:**
- Press `:` then `vim largefile`

**Need GUI file manager:**
- Use xdg-open on directory: `:xdg-open .`

**Kitty image flash:**
- Use mlterm or xterm for better image support
- Or accept brief flash in kitty

## Still Having Issues?

1. **Update everything:**
   ```bash
   gem update rtfm-filemanager rcurses termpix
   ```

2. **Check GitHub issues:**
   https://github.com/isene/RTFM/issues

3. **Report new bug:**
   Include version info, error message, steps to reproduce

4. **Email author:**
   g@isene.com

---

[← Plugins](plugins.md) | [Next: FAQ →](faq.md)
