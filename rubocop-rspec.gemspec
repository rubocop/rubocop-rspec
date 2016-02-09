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
  spec.authors = ['Ian MacLeod', 'Nils Gemeinhardt']
  spec.email = ['ian@nevir.net', 'git@nilsgemeinhardt.de']
  spec.licenses = ['MIT']

  spec.version = RuboCop::RSpec::Version::STRING
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 1.9.3'

  spec.require_paths = ['lib']
  spec.files = Dir[
    '{config,lib,spec}/**/*',
    '*.md',
    '*.gemspec',
    'Gemfile',
    'Rakefile'
  ]
  spec.test_files = spec.files.grep(%r{^spec/})
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.add_development_dependency('rubocop', '~> 0.36')
  spec.add_development_dependency('rake', '~> 10.1')
  spec.add_development_dependency('rspec', '~> 3.0')
  spec.add_development_dependency('simplecov', '~> 0.8')
end
