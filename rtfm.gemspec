Gem::Specification.new do |s|
  s.name        = 'rtfm-filemanager'
  s.version     = '6.0.4'
  s.licenses    = ['Unlicense']
  s.summary     = "RTFM - Ruby Terminal File Manager"
  s.description = "Major release - RTFM v6.0: Remote SSH/SFTP browsing with seamless navigation, interactive SSH shell integration, enhanced help system with color-coded formatting, SSH connection comments, comprehensive undo system, and performance optimizations.\n A full featured terminal browser with syntax highlighted files, images shown in the terminal, videos thumbnailed, etc. You can bookmark and jump around easily, delete, rename, copy, symlink and move files. RTFM is one of the most feature-packed terminal file managers."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rtfm", "README.md", "img/rtfm-kb.png", "img/logo.png"]
  s.add_runtime_dependency 'rcurses', '~> 4.9.5'
  s.add_runtime_dependency 'bootsnap', '~> 1.18'
  s.add_runtime_dependency 'ruby-openai', '~> 7.4'
  s.executables << 'rtfm'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/RTFM" }
end
