# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/rspec/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-rspec'
  spec.summary = 'Code style checking for RSpec files'
  spec.description = <<~DESCRIPTION
    Code style checking for RSpec files.
    A plugin for the RuboCop code style enforcing & linting tool.
  DESCRIPTION
  spec.homepage = 'https://github.com/rubocop/rubocop-rspec'
  spec.authors = ['John Backus', 'Ian MacLeod', 'Nils Gemeinhardt']
  spec.email = [
    'johncbackus@gmail.com',
    'ian@nevir.net',
    'git@nilsgemeinhardt.de'
  ]
  spec.licenses = ['MIT']

  spec.version = RuboCop::RSpec::Version::STRING
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'

  spec.require_paths = ['lib']
  spec.files = Dir[
    'lib/**/*',
    'config/*',
    '*.md'
  ]
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.metadata = {
    'changelog_uri' => 'https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://docs.rubocop.org/rubocop-rspec/',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'rubocop', '~> 1.40'
  spec.add_runtime_dependency 'rubocop-capybara', '~> 2.17'
  spec.add_runtime_dependency 'rubocop-factory_bot', '~> 2.22'
  spec.add_runtime_dependency 'rubocop-rspec_rails', '~> 2.28'
end
