require './lib/markdoc/version'

Gem::Specification.new do |s|
  s.name        = 'markdoc'
  s.version     = Markdoc::VERSION
  s.date        = '2015-04-10'
  s.summary     = "Markdown to HTML converter with diagrams"
  s.description = "Markdown with support for pseudocode to flowchart and sequence diagram generation"
  s.authors     = ["Lkhagva Ochirkhuyag"]
  s.email       = 'ochkoo@gmail.com'
  s.executables << 'markdoc'
  s.homepage    = 'https://github.com/ochko/markdoc'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'polyglot',    '~> 0.3'
  s.add_runtime_dependency 'redcarpet',   '~> 3.2'
  s.add_runtime_dependency 'treetop',     '~> 1.6'
  s.add_runtime_dependency 'pygments.rb', '~> 0.6'

  s.require_paths = ['lib']
  s.files         = [
    'lib/markdoc.rb',
    'lib/markdoc/pseudocode.rb',
	  'lib/markdoc/pseudocode.treetop',
	  'lib/markdoc/renderer.rb',
	  'lib/markdoc/sequence.rb',
	  'lib/markdoc/version.rb',
    'bin/markdoc',
    'bin/pseudo2svg',
    'bin/sequence2svg'
  ]
end
