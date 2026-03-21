# RTFM Plugin API Reference

Technical reference for building RTFM plugins.

## Plugin File Location

Plugins live in `~/.rtfm/plugins/` as `.rb` files.
Disabled plugins have a `.rb.off` extension.

RTFM also loads two legacy files if present:

- `~/.rtfm/preview.rb` for custom preview handlers
- `~/.rtfm/keys.rb` for custom key bindings

## Metadata Format

Each plugin should start with comment headers:

```ruby
# @name: My Plugin
# @description: Short summary of what the plugin does
# @key: X
```

| Header         | Required | Description                              |
|----------------|----------|------------------------------------------|
| `@name:`       | Yes      | Display name shown in plugin manager     |
| `@description:`| Yes      | One-line summary for plugin manager list |
| `@key:`        | No       | Documents the key binding (informational)|

If `@name:` is omitted, the filename (minus `.rb`) is used.

## Plugin Types

### key_handler

Binds a key to a Ruby method. The method receives the
pressed character as its first argument.

```ruby
# @name: Hello
# @description: Greets the user
# @key: H

KEYMAP['H'] = :hello_handler

def hello_handler(_chr)
  @pB.say("Hello from the plugin!")
end
```

A plugin may register multiple keys by adding entries
to the `KEYMAP` hash. Use `PLUGIN_HELP` to register
help text shown in the plugin manager:

```ruby
PLUGIN_HELP['Hello'] = <<~HELP
  Press H to see a greeting.
HELP
```

### preview_handler

Adds custom file preview commands via `~/.rtfm/preview.rb`.
Each line maps file extensions to a shell command:

```ruby
# extension1, extension2 = command with @s placeholder
md = pandoc @s -t plain
json = jq -C . @s
```

`@s` is replaced with the shell-escaped filename at runtime.

## Available Variables

### Pane Objects

| Variable    | Description             |
|-------------|-------------------------|
| `@pT`       | Top pane (path bar)     |
| `@pL`       | Left pane (file list)   |
| `@pR`       | Right pane (preview)    |
| `@pB`       | Bottom pane (status)    |
| `@pCmd`     | Command prompt pane     |
| `@pSearch`  | Search prompt pane      |
| `@pAI`      | AI chat pane            |
| `@pRuby`    | Ruby debug pane         |

Pane methods:

```ruby
@pR.say("text")      # Display text in pane
@pR.clear             # Clear pane content
@pR.update = true     # Mark pane for refresh
@pR.refresh           # Force immediate refresh
@pCmd.ask("prompt: ","default")  # Get user input
```

### File and State Variables

| Variable     | Type    | Description                        |
|--------------|---------|------------------------------------|
| `@selected`  | String  | Full path of highlighted item      |
| `@directory` | Hash    | Maps directory paths to last index |
| `@tagged`    | Array   | Paths of tagged items              |
| `@marks`     | Hash    | Bookmarks (`{'a' => '/path'}`)     |
| `@files`     | Array   | Current directory file list        |
| `@index`     | Integer | Index of selected item in @files   |
| `@w` / `@h`  | Integer | Terminal width / height            |
| `@preview`   | Boolean | Preview enabled                    |
| `@showimage` | Boolean | Image preview enabled              |
| `@trash`     | Boolean | Trash bin enabled                  |
| `@remote_mode` | Boolean | SSH remote mode active           |
| `@archive_mode`| Boolean | Archive browsing active          |

### Error Tracking

| Variable         | Type  | Description                     |
|------------------|-------|---------------------------------|
| `@plugin_errors` | Array | Collects plugin load errors     |

Errors added here are displayed after startup.

## Plugin Lifecycle

1. **Scan**: RTFM scans `~/.rtfm/plugins/` for `*.rb` and
   `*.rb.off` files on startup.
2. **Parse metadata**: Comment headers are extracted from
   each file.
3. **Load**: Enabled plugins (`.rb` extension) are loaded
   via Ruby's `load`. The KEYMAP is snapshotted before and
   after to track which keys the plugin adds or changes.
4. **Enable/Disable**: The plugin manager (`V` key) toggles
   plugins at runtime. Disabling renames the file to `.off`
   and restores the KEYMAP snapshot. Enabling renames back
   to `.rb` and reloads.
5. **Toggle**: `toggle_plugin(name)` handles the rename and
   reload/unload cycle.

## Error Handling

Plugin errors are caught as `StandardError` and appended to
`@plugin_errors`. They do not crash RTFM.

If your plugin needs to report errors to the user at runtime:

```ruby
@pB.say("Error: something went wrong".fg(196))
```

For errors during load, RTFM shows them automatically.

## Helper Functions

```ruby
command(cmd, timeout: 5)      # Run shell command, capture output
shell(cmd, background: false) # Run shell command
shellexec(cmd, timeout: 10)   # Run and show output in right pane
cmd?("program")               # Check if program is on PATH
clear_image                   # Clear any displayed image
showimage(path)               # Display image in right pane
refresh                       # Refresh layout
render                        # Render all panes
add_undo_operation(info)      # Add to undo history
```

## Example: Minimal Plugin

```ruby
# @name: Word Count
# @description: Show word count of selected file
# @key: C-W

KEYMAP['C-W'] = :word_count

def word_count(_chr)
  return @pB.say("Select a file first") unless @selected && File.file?(@selected)
  output = command("wc -w #{Shellwords.escape(@selected)}")
  @pB.say("Words: #{output.split.first}")
end
```

Save this as `~/.rtfm/plugins/wordcount.rb` and restart RTFM,
or toggle it on with `V`.

---

[< Plugins Guide](plugins.md) | [Back to README](../README.md)
