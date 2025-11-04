# Contributing to RTFM

Thank you for your interest in contributing to RTFM!

## Philosophy

RTFM is a personal project built to fit my needs. I don't expect widespread use, but I welcome contributions that align with the project's goals:

- **Feature-rich** - More features is better
- **Terminal-native** - Respect LS_COLORS, work in any terminal
- **Ruby-based** - Pure Ruby, readable code
- **Single file** - Keep it in one file for simplicity
- **Well-documented** - Good docs matter

## Ways to Contribute

### 1. Bug Reports

**Great bug reports include:**
- RTFM version (`rtfm --version` or press `v`)
- Ruby version (`ruby --version`)
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Error messages (if any)

**Submit at:** https://github.com/isene/RTFM/issues

### 2. Feature Requests

**Before requesting:**
- Check existing issues
- Consider if it fits RTFM's philosophy
- Describe the use case, not just the feature

**Good feature requests include:**
- Problem you're trying to solve
- How you'd use the feature
- Why existing features don't work
- Willingness to test

**I may or may not implement** - If it's cool and fits my needs, probably yes!

### 3. Code Contributions

#### Pull Requests Welcome For:
- Bug fixes
- Performance improvements
- Documentation improvements
- Test coverage
- Code cleanup

#### Before Submitting:
1. Open an issue to discuss major changes
2. Follow existing code style
3. Test thoroughly
4. Update documentation if needed

#### Code Style:
- Use vim fold markers `# {{{` and `# }}}`
- Comment complex logic
- Keep methods focused and small
- Use descriptive variable names
- Follow Ruby conventions

#### Testing:
```bash
# Test RTFM manually
ruby bin/rtfm

# Test in different scenarios:
# - Large directories (1000+ files)
# - Image directories
# - Remote mode
# - With preview on/off
```

### 4. Documentation

**Always welcome:**
- Typo fixes
- Clarifications
- Examples
- Translations (if you're ambitious!)

**Areas needing help:**
- Video tutorials
- GIF demos of features
- More plugin examples
- Use case documentation

### 5. Plugins

**Share your plugins!**
- Post as GitHub gist
- Open issue to showcase
- Submit PR to add to examples/

**Plugin ideas:**
- Workflow automation
- Integration with other tools
- Custom file handlers
- Specialized operations

## Development Setup

### Clone Repository

```bash
git clone https://github.com/isene/RTFM.git
cd RTFM
```

### Install Dependencies

```bash
gem install rcurses termpix bootsnap
# Optional for all features:
sudo apt install imagemagick w3m-img xdotool bat pandoc
```

### Run from Source

```bash
ruby bin/rtfm
```

### Code Organization

RTFM is a single file (`bin/rtfm`) organized with vim folds:

```
# BASIC SETUP {{{1
  # Subsection {{{2
    # Function {{{3
```

Use vim to navigate: `zo` to open fold, `zc` to close.

### Key Areas

| Line Range | Section |
|------------|---------|
| 1-500 | Setup, config, help text |
| 500-1500 | Key handlers, basic navigation |
| 1500-2500 | Tagging, marks, undo system |
| 2500-3500 | Remote mode, file operations |
| 3500-4500 | Git, AI, system info |
| 4500-5500 | Rendering, caching |
| 5500-6000 | Preview handlers, main loop |

## Coding Guidelines

### Do:
- ✓ Use existing patterns and conventions
- ✓ Add helpful comments
- ✓ Handle errors gracefully
- ✓ Test edge cases
- ✓ Update help text for new features
- ✓ Consider performance impact

### Don't:
- ✗ Break existing functionality
- ✗ Add dependencies without discussion
- ✗ Make breaking changes without major version
- ✗ Sacrifice performance for minor features
- ✗ Add platform-specific code without fallbacks

## Submitting Pull Requests

### PR Checklist:
- [ ] Issue opened and discussed (for major changes)
- [ ] Code tested manually
- [ ] Documentation updated
- [ ] Help text updated (if new feature)
- [ ] CHANGELOG.md entry added
- [ ] Commit messages are clear

### Commit Message Format:

```
Brief description of change

Detailed explanation if needed.

- Bullet points for multiple changes
- Reference issues: Fixes #123
```

### PR Title Format:

```
Fix: Brief description
Feature: Brief description
Docs: Brief description
Performance: Brief description
```

## Testing Checklist

Before submitting PR, test:

**Basic Operations:**
- [ ] Navigation (up/down/left/right)
- [ ] File preview
- [ ] Image display
- [ ] File operations (copy/move/delete)
- [ ] Tagging
- [ ] Bookmarks

**Advanced Features:**
- [ ] Remote mode (if applicable)
- [ ] Undo system (if applicable)
- [ ] Configuration loading
- [ ] Terminal resize

**Edge Cases:**
- [ ] Empty directories
- [ ] Large files
- [ ] Special characters in filenames
- [ ] Broken symlinks
- [ ] Permission denied scenarios

## Release Process

**I handle releases**, but if you're curious:

1. Update version in `bin/rtfm` and `rtfm.gemspec`
2. Update `CHANGELOG.md`
3. Commit: `Version X.Y.Z: Description`
4. Build: `gem build rtfm.gemspec`
5. Publish: `gem push rtfm-filemanager-X.Y.Z.gem`
6. Tag: `git tag X.Y.Z && git push --tags`
7. GitHub release

## Questions?

- **Email:** g@isene.com
- **GitHub Issues:** https://github.com/isene/RTFM/issues
- **GitHub Discussions:** *(if enabled)*

## License

All contributions are released under the Unlicense (public domain).

By contributing, you agree to release your contributions to the public domain.

## Thank You!

Every contribution helps make RTFM better. Whether it's a bug report, feature idea, or code contribution - thank you for taking the time!

---

**Happy hacking!** 🚀
