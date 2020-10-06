require './lib/markdoc/version'

Gem::Specification.new do |s|
  s.name        = 'markdoc'
  s.version     = Markdoc::VERSION
  s.summary     = "Markdown to HTML converter with diagrams"
  s.description = "Markdown with support for pseudocode to flowchart and sequence diagram generation"
  s.authors     = ["Lkhagva Ochirkhuyag"]
  s.email       = 'ochkoo@gmail.com'
  s.homepage    = 'https://github.com/ochko/markdoc'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'polyglot',    '~> 0.3'
  s.add_runtime_dependency 'redcarpet',   '~> 3.2'
  s.add_runtime_dependency 'treetop',     '~> 1.6'
  s.add_runtime_dependency 'pygments.rb'

  s.add_development_dependency('rake', '> 10.0.0')

  s.executables << 'markdoc'
  s.executables << 'pseudo2svg'
  s.executables << 'sequence2svg'

  s.require_paths = ['lib']
  s.files         = [
    'lib/markdoc.rb',
    'lib/markdoc/pseudocode.rb',
	  'lib/markdoc/pseudocode.treetop',
	  'lib/markdoc/renderer.rb',
	  'lib/markdoc/sequence.rb',
	  'lib/markdoc/version.rb',
    'css/style.css',
    'css/pygments.css',
    'bin/markdoc',
    'bin/pseudo2svg',
    'bin/sequence2svg'
  ]
end
