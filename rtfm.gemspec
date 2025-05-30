Gem::Specification.new do |s|
  s.name        = 'rtfm-filemanager'
  s.version     = '5.6.1'
  s.licenses    = ['Unlicense']
  s.summary     = "RTFM - Ruby Terminal File Manager"
  s.description = "Major release - RTFM v5: Complete rewrite using rcurses (https://github.com/isene/rcurses). Massive improvements. AI integration.\n A full featured terminal browser with syntax highlighted files, images shown in the terminal, videos thumbnailed, etc. You can bookmark and jump around easily, delete, rename, copy, symlink and move files. RTFM is one of the most feature-packed terminal file managers. 5.6.1: Fixed a small copy path bug."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rtfm", "README.md", "img/rtfm-kb.png", "img/logo.png"]
  s.add_runtime_dependency 'rcurses', '~> 3.7.4'
  s.add_runtime_dependency 'bootsnap', '~> 1.18'
  s.add_runtime_dependency 'ruby-openai', '~> 7.4'
  s.executables << 'rtfm'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/RTFM" }
end
