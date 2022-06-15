# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc 'Run tests'
task default: :test

desc 'Testing usage for fast iteration'
task :usage do
  puts 'gem uninstall markdoc -x'
  puts `gem uninstall markdoc -x`

  puts 'gem build markdoc.gemspec'
  puts `gem build markdoc.gemspec`

  puts 'gem install markdoc-*.gem --no-ri --no-rdoc'
  puts `gem install markdoc-*.gem --no-ri --no-rdoc`

  puts 'markdoc examples/doc.md'
  puts `markdoc examples/doc.md`

  `rm -f markdoc-*.gem`
end
