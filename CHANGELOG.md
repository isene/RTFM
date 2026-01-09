# Changelog

All notable changes to RTFM will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.4.4] - 2026-01-09

### Fixed
- **Extract command ('z') improvements** - Fixed two issues with archive extraction:
  - Now uses current file when nothing is tagged (was empty command before)
  - Auto-detects archive type and suggests correct command:
    - `.zip` → `unzip`
    - `.rar` → `unrar x`
    - `.7z` → `7z x`
    - `.tar.bz2`/`.tbz2` → `tar xfj`
    - `.tar.xz`/`.txz` → `tar xfJ`
    - `.tar.zst` → `tar --zstd -xf`
    - Others → `tar xfz`

## [7.4.3] - 2025-12-09

### Fixed
- **Display corruption with .docx files** - Fixed left pane display corruption when viewing .docx files
  - Carriage returns (`\r`) from docx2txt output were moving cursor to beginning of line
  - This caused the right pane content to overwrite the left pane's first item prefix
  - Added `tr -d '\r'` filter to docx handler, matching existing PDF handler behavior
  - Left pane file list now displays correctly when previewing Word documents

## [7.4.1] - 2025-11-04

### Fixed
- **Directory cache invalidation** - Cache now includes file count in addition to mtime
  - Fixes issue where files created by external processes didn't appear
  - Cache automatically invalidates when files are added or deleted
  - More reliable detection of directory changes across filesystems

## [7.4.0] - 2025-11-03

### Documentation
- **Man page added** - Professional Unix-style documentation (man rtfm)
- **Restructured README** - Better organization, TOC, quick start guide
- **Comprehensive guides** created in docs/ directory:
  - Getting Started guide
  - Configuration reference
  - Remote browsing guide
  - Keyboard reference
  - Plugin development guide
  - Troubleshooting guide
  - FAQ
- **Example configuration** - Well-commented rtfm.conf template
- **CONTRIBUTING.md** - Guidelines for contributors
- **Documentation badge** added to README

### Changed
- All documentation files now distributed with gem
- gemspec includes man page, docs/, and examples/

## [7.3.6] - 2025-11-03

### Fixed
- Preview toggle ('-') now properly clears displayed images
- Image preview toggle ('_') now properly clears displayed images
- Image/PDF metadata only fetched when preview is ON (eliminates lag with preview OFF)

### Performance
- No identify/pdfinfo calls when preview is disabled
- Faster navigation through directories when preview OFF
- Benefits from termpix 0.2.1 conditional auto-orient

## [7.3.5] - 2025-10-27

### Fixed
- Images now properly clear when navigating to different directories
- Added image clearing to: jump_to_mark ('), move_left/up (h/LEFT), go_home (~), follow_symlink (>), and directory entry

## [7.3.4] - 2025-10-27

### Fixed
- Critical bug: Undefined variable 'esc' in permanent delete operation (when trash is disabled)
- Permanent deletion now works correctly

## [7.3.3] - 2025-10-27

### Performance
- Image redraw checking now only runs when idle (no keypress)
- Eliminates delay during active use with large images displayed
- UP/DOWN/? and other keys now instant even with large images

### Added
- UTF-16 file support (both LE and BE) for opening in $EDITOR
- Files with UTF-16 encoding now properly detected as text

### Fixed
- Added clear_image helper function to reduce code duplication
- Image clearing for help, delete, config, git, system info, compare, tagged operations

## [7.3.2] - 2025-10-27

### Added
- C-Y now copies image files to clipboard when viewing images (can paste into GIMP, etc.)
- MIME type detection for image clipboard copy (PNG, JPEG, GIF, BMP, WebP)

### Fixed
- Images now persist during operations (copy path, change permissions, etc.)
- Image display no longer cleared unnecessarily during key operations

### Improved
- Removed aggressive image clearing in key handler
- Images only clear when content actually changes

## [7.3.1] - 2025-10-27

### Fixed
- Image positioning now uses correct absolute row positioning (row 2)
- Images with EXIF orientation metadata display correctly (via termpix 0.2.0)
- Pane borders no longer cleared when displaying images

### Changed
- Updated termpix dependency to ~> 0.2 for EXIF auto-orient support

## [7.3.0] - 2025-10-26

### Added
- Modern image display using termpix gem with multi-protocol support
- Sixel protocol support for mlterm and compatible terminals
- Protocol detection shown in version display (press 'v')

### Changed
- Refactored image display to use termpix gem instead of direct w3m calls
- Cleaner, more maintainable image handling code
- Better terminal compatibility across different emulators

### Improved
- Image display now supports multiple protocols (Sixel, w3m)
- Reduced code complexity in showimage function (~50 lines to ~20)
- Better separation of concerns (image protocols in dedicated gem)

## [7.2.1] - 2025-10-25

### Performance
- Window title update optimization: Use direct print instead of system spawn
- Eliminates process spawn overhead (~2-5ms) on every directory change
- Snappier directory navigation experience

---

## [7.2.0] - 2025-10-21

### BREAKING CHANGES
**Batch Operation Behavior Change:**
- All batch operations now use a consistent "tagged OR selected" logic
- When items are tagged: operations work ONLY on tagged items (selected item is NOT included unless also tagged)
- When NO items are tagged: operations work on the currently selected item only
- This affects: delete, copy, move, symlink, bulk rename, change permissions, change ownership, and open operations
- **Migration**: If you previously relied on operations affecting "tagged + selected", you must now explicitly tag the selected item if you want it included

### Why This Change
This change provides consistent, predictable behavior across all batch operations and eliminates confusion about which items will be affected by an operation.

### Added
- Permission modification syntax: Use `+x`, `-w`, `+rw`, etc. to add/remove permissions incrementally
- Undo support for permission changes (C-P)
- Undo support for ownership changes (C-O)
- Persistent selection: After delete/move operations, the previously selected item remains selected if it still exists

### Improved
- Bulk rename now works on single selected item when no items are tagged (consistent with other operations)

## [7.1.4] - 2025-10-21

### Fixed
- Terminal resizing now works properly in window managers like i3-wm
- Added error handling to WINCH signal handler to prevent crashes on resize
- Manual refresh ('r' key) now re-reads and applies new terminal size
- Terminal size validation prevents invalid dimensions from being applied

## [7.1.3] - 2025-10-21

### Fixed
- Permission change (C-P) now properly updates file colors in the display by invalidating the directory cache
- Broken symlinks can now be deleted or moved to trash without errors

## [7.1.2] - 2025-10-19

### Fixed
- Text file preview now works for all text-encoded files using `file` command MIME type detection

## [7.1.1] - 2025-10-18

### Fixed
- 'A' key toggle_long now properly shows ls -l format
- Cache invalidation when toggling long file info display

## [7.1.0] - 2025-10-17

### Added
- Compressed archive viewer support for .zip, .tar, .gz, .bz2, .xz, .rar, and .7z files
- Archive contents preview in right pane

## [7.0.14] - 2025-10-16

### Fixed
- Regex error when using '*' to mark all files with C-T
