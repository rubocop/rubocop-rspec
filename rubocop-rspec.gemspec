# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rubocop/rspec/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-rspec'
  spec.summary = 'Code style checking for RSpec files'
  spec.description = <<-end_description
    Code style checking for RSpec files.
    A plugin for the RuboCop code style enforcing & linting tool.
  end_description
  spec.homepage = 'http://github.com/nevir/rubocop-rspec'
  spec.authors = ['Ian MacLeod']
  spec.email = ['ian@nevir.net']
  spec.licenses = ['MIT']

  spec.version = Rubocop::RSpec::Version::STRING
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 1.9.2'

  spec.require_paths = ['lib']
  spec.files = Dir['**/*']
  spec.test_files = spec.files.grep(/^spec\//)
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.add_runtime_dependency('rubocop', '~> 0.17')
end
