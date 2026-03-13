Gem::Specification.new do |s|
  s.name        = 'rtfm-filemanager'
  s.version     = '8.1.2'
  s.licenses    = ['Unlicense']
  s.summary     = "RTFM - Ruby Terminal File Manager"
  s.description = "RTFM v8.0: Browse and modify archives as virtual directories (extract, delete, add, move), async background file operations, scrollable diff viewer with side-by-side mode. A full featured terminal browser with syntax highlighted files, images shown in the terminal, videos thumbnailed, etc. Features include remote SSH/SFTP browsing, interactive SSH shell, comprehensive undo system, OpenAI integration, bookmarks, and much more. RTFM is one of the most feature-packed terminal file managers. v8.1: File picker mode (--pick) for integration with other tools."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = [
    "bin/rtfm",
    "README.md",
    "CHANGELOG.md",
    "img/rtfm-kb.png",
    "img/logo.png",
    "man/rtfm.1",
    "docs/getting-started.md",
    "docs/configuration.md",
    "docs/remote-browsing.md",
    "docs/keyboard-reference.md",
    "docs/plugins.md",
    "docs/troubleshooting.md",
    "docs/faq.md",
    "examples/rtfm.conf"
  ]
  s.add_runtime_dependency 'rcurses', '~> 6.0'
  s.add_runtime_dependency 'termpix', '~> 0.3'
  s.add_runtime_dependency 'bootsnap', '~> 1.18'
  s.add_runtime_dependency 'ruby-openai', '~> 7.4'
  s.executables << 'rtfm'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/RTFM" }
end
