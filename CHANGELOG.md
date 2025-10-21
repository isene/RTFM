# Changelog

All notable changes to RTFM will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
