# Remote SSH/SFTP Browsing

Complete guide to RTFM's remote directory browsing capabilities.

## Overview

RTFM lets you browse and manage files on remote servers via SSH/SFTP as seamlessly as local directories. No need to open separate terminal windows or use command-line scp/sftp.

## Quick Start

1. Press `Ctrl-e` to enter remote mode
2. Enter connection: `user@server.com:/path/to/directory`
3. Navigate with normal keys
4. Press `d` to download, `u` to upload
5. Press `Ctrl-e` to return to local mode

## Connection Formats

### Basic SSH Connection

```
user@hostname:/path/to/directory
```

### With Custom SSH Key

```
-i ~/.ssh/custom-key user@hostname:/path
```

Or:
```
user@hostname:/path -i ~/.ssh/custom-key
```

### SSH URI Format

```
ssh://user@hostname/path/to/directory
```

### IP Address

```
user@192.168.1.100:/home/user
```

### With Comments (for organization)

```
user@production.com:/var/www # Production server
admin@dev.local:/home # Development
backup@backup.server:/data # Backup server
```

Comments help identify connections in history (`Ctrl-e` then select from list).

## Remote Mode Operations

### Navigation

| Key | Action |
|-----|--------|
| `↑` `↓` | Move through file list |
| `→` `ENTER` | Show file info |
| `←` `h` | Parent directory |
| `HOME` `END` | First / last item |

### File Operations

| Key | Action |
|-----|--------|
| `d` | Download selected file |
| `u` | Upload tagged files |
| `s` | Open SSH shell in current directory |

**Note:** Copy, move, delete operations are disabled in remote mode for safety.

### Information Display

Press `→` or `ENTER` on a file to see:
- File size
- Permissions
- Owner/group
- Modified date
- Full path

## Downloading Files

### Download Single File

1. Navigate to file
2. Press `d`
3. File downloads to your current local directory

### Download Multiple Files

1. Tag files with `t`
2. Press `d`
3. All tagged files download

**Download location:** Current local directory (where you were before entering remote mode)

## Uploading Files

### Upload Tagged Files

1. In local mode, tag files with `t`
2. Press `Ctrl-e` to enter remote mode
3. Navigate to destination directory
4. Press `u` to upload all tagged files

### Upload Workflow Example

```bash
# Local mode
r                           # Launch RTFM
# Navigate to files to upload
t t t                      # Tag 3 files
Ctrl-e                     # Enter remote mode
user@server:/uploads      # Connect
# Navigate to destination
u                          # Upload tagged files
```

## SSH Shell Integration

### Opening SSH Shell

While in remote mode:
1. Navigate to desired directory
2. Press `s`
3. Interactive SSH shell opens in that directory

### In SSH Shell

- Full interactive shell session
- All normal shell commands work
- Exit shell with `exit` or `Ctrl-d`
- Returns to RTFM automatically

**Use case:** Quick edits, running scripts, checking logs

## Connection Caching

RTFM caches remote directory listings for 60 seconds to improve performance.

**Force refresh:**
- Press `r` to refresh current directory
- Change directories and return

## SSH Configuration

### SSH Key Setup

For passwordless access, set up SSH keys:

```bash
# Generate key (if you don't have one)
ssh-keygen -t ed25519

# Copy to server
ssh-copy-id user@server.com
```

### Persistent Connections

Speed up repeated connections in `~/.ssh/config`:

```
Host production
    HostName production.example.com
    User deployuser
    IdentityFile ~/.ssh/production_key
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m

Host *.local
    User admin
    ControlMaster auto
    ControlPersist 5m
```

Then in RTFM: `Ctrl-e` → `production:/var/www`

## Connection History

RTFM saves recent SSH connections in `@sshhistory`.

**Prepopulate connections:**

```ruby
# ~/.rtfm/conf
@sshhistory = [
  "user@production.com:/var/www # Production",
  "admin@staging.com:/var/www # Staging",
  "user@backup.server:/backups # Backups"
]
```

**Access history:**
1. Press `Ctrl-e`
2. See list of recent connections
3. Select connection or enter new one

## Use Cases

### Remote Log Monitoring

```
Ctrl-e → server:/var/log → Navigate to log → ENTER (view content)
```

### Deploy Files

```
Tag local files → Ctrl-e → server:/var/www → u (upload)
```

### Backup Files

```
Ctrl-e → server:/data → Tag files → d (download)
```

### Quick Config Edit

```
Ctrl-e → server:/etc → Navigate to config → s (shell) → vim config
```

### Multi-Server File Distribution

```
Tag files locally → Ctrl-e → server1:/dest → u (upload)
Ctrl-e → server2:/dest → u (upload again)
```

## Troubleshooting

### Connection Fails

**Check SSH access:**
```bash
ssh user@hostname
```

If this works, RTFM should work.

**Common issues:**
- Wrong username or hostname
- SSH key not configured
- Firewall blocking port 22
- Path doesn't exist on server

### Slow Performance

1. **Enable SSH connection caching** (see SSH Configuration above)
2. **Use SSH config aliases** for complex connections
3. **Reduce SFTP overhead** with persistent connections

### Permission Denied

- Check user has access to remote directory
- Verify SSH key permissions: `chmod 600 ~/.ssh/id_*`
- Check server's `~/.ssh/authorized_keys`

### Files Don't Appear

- Press `r` to refresh directory listing
- Check if files exist: Press `s` to open shell, run `ls`

### Upload Fails

- Check destination directory exists and is writable
- Verify sufficient disk space on server
- Check file permissions locally

## Advanced SSH Techniques

### Jump Hosts

Configure in `~/.ssh/config`:
```
Host production
    HostName internal.server.com
    ProxyJump jumphost.example.com
    User deployuser
```

Then: `Ctrl-e` → `production:/path`

### Port Forwarding

```
Host database
    HostName localhost
    Port 5432
    User postgres
    LocalForward 5432 db.internal:5432
    ProxyJump jumphost
```

### Multiple Identities

```ruby
# Different keys for different servers
@sshhistory = [
  "-i ~/.ssh/work_key user@work.com:/projects",
  "-i ~/.ssh/personal_key user@personal.com:/files"
]
```

## Security Considerations

### Best Practices

1. **Use SSH keys** - Never use password authentication
2. **Restrict key permissions** - `chmod 600 ~/.ssh/id_*`
3. **Use different keys** - Different keys for different servers
4. **Limited user accounts** - Don't use root for SFTP
5. **Monitor uploads** - Review what you're uploading

### What RTFM Sends

RTFM uses standard SFTP protocol - same as:
```bash
sftp user@hostname
```

No passwords are stored. SSH key authentication only.

## Performance Tips

### Faster Browsing

1. **Persistent connections** - Configure ControlMaster (see above)
2. **Compression** - Add to `~/.ssh/config`: `Compression yes`
3. **Disable strict checking** - For trusted networks: `StrictHostKeyChecking accept-new`

### Large File Transfers

For very large files, consider using rsync outside RTFM:
```bash
rsync -avP largefile.tar.gz user@server:/path/
```

RTFM is optimized for browsing and quick file transfers, not bulk data transfer.

## Limitations

**Remote mode restrictions:**
- No file deletion (safety)
- No file moving (safety)
- No permission changes (safety)
- Read-only except download/upload

**Why?** Safety first. Use SSH shell (`s` key) for destructive operations.

## Examples

### Example 1: Deploy Website

```
# Local: Tag files to deploy
t t t (tag HTML, CSS, JS)

# Enter remote mode
Ctrl-e
user@webserver:/var/www/html

# Upload
u

# Verify
→ (check file info)

# Exit
Ctrl-e
```

### Example 2: Download Logs

```
# Connect to server
Ctrl-e
admin@logserver:/var/log

# Tag logs
t t t

# Download
d

# Exit and analyze locally
Ctrl-e
```

### Example 3: Quick Config Edit

```
# Connect
Ctrl-e
root@server:/etc

# Navigate to config
# (use arrow keys)

# Open shell
s

# Edit
vim nginx.conf

# Exit shell (back to RTFM)
exit

# Exit remote mode
Ctrl-e
```

---

[← Configuration](configuration.md) | [Next: Keyboard Reference →](keyboard-reference.md)
