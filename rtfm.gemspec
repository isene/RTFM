Gem::Specification.new do |s|
  s.name        = 'rtfm-filemanager'
  s.version     = '3.33'
  s.licenses    = ['Unlicense']
  s.summary     = "RTFM - Ruby Terminal File Manager"
  s.description = "A full featured terminal browser with syntax highlighted files, images shown in the terminal, videos thumbnailed, etc. You can bookmark and jump around easily, delete, rename, copy, symlink and move files. RTFM has a a wide range of other features. New in 3.33: Bugfix after fixing forking upon opening external apps."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rtfm", "README.md", "img/rtfm-kb.png"]
  s.add_runtime_dependency 'curses', '~> 1.3', '>= 1.3.2'
  s.add_runtime_dependency 'ruby-openai', '~> 3.0'
  s.executables << 'rtfm'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/RTFM" }
end