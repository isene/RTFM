version = File.read(File.join(__dir__, 'bin/rtfm'))[/@version\s*=\s*'([^']+)'/, 1]
Gem::Specification.new do |s|
  s.name        = 'rtfm-filemanager'
  s.version     = version
  s.licenses    = ['Unlicense']
  s.summary     = "RTFM - Ruby Terminal File Manager"
  s.description = "A full featured terminal file manager with syntax highlighted files, images shown in the terminal, videos thumbnailed, etc. Features include remote SSH/SFTP browsing, interactive SSH shell, comprehensive undo system, OpenAI integration, bookmarks, archive browsing, and much more. v8.2: Plugin system with live enable/disable, built-in plugin manager (V key), and example plugins (settings editor, git operations, bookmarks, notes, custom file openers)."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = [
    "bin/rtfm",
    "README.md",
    "CHANGELOG.md",
    "img/rtfm-kb.svg",
    "img/logo.png",
    "man/rtfm.1",
    "docs/getting-started.md",
    "docs/configuration.md",
    "docs/remote-browsing.md",
    "docs/keyboard-reference.md",
    "docs/plugins.md",
    "docs/troubleshooting.md",
    "docs/faq.md",
    "examples/rtfm.conf",
    "examples/settings.rb",
    "examples/git.rb",
    "examples/bookmarks.rb",
    "examples/notes.rb",
    "examples/opener.rb",
    "examples/diskusage.rb",
    "examples/dupes.rb"
  ]
  s.add_runtime_dependency 'rcurses', '~> 7.0'
  s.add_runtime_dependency 'termpix', '~> 0.3'
  s.add_runtime_dependency 'bootsnap', '~> 1.18'
  s.add_runtime_dependency 'ruby-openai', '~> 7.4'
  s.executables << 'rtfm'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/RTFM" }
end
