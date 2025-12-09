Gem::Specification.new do |s|
  s.name        = 'rtfm-filemanager'
  s.version     = '7.4.3'
  s.licenses    = ['Unlicense']
  s.summary     = "RTFM - Ruby Terminal File Manager"
  s.description = "RTFM v7.4.3: Fixed display corruption when viewing .docx files by filtering carriage returns from docx2txt output.\n A full featured terminal browser with syntax highlighted files, images shown in the terminal, videos thumbnailed, etc. Features include remote SSH/SFTP browsing, interactive SSH shell, comprehensive undo system, bookmarks, and much more. You can bookmark and jump around easily, delete, rename, copy, symlink and move files. RTFM is one of the most feature-packed terminal file managers."
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
  s.add_runtime_dependency 'termpix', '~> 0.2'
  s.add_runtime_dependency 'bootsnap', '~> 1.18'
  s.add_runtime_dependency 'ruby-openai', '~> 7.4'
  s.executables << 'rtfm'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/RTFM" }
end
