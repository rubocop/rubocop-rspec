# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/rspec/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-rspec'
  spec.summary = 'Code style checking for RSpec files'
  spec.description = <<-DESCRIPTION
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
  spec.required_ruby_version = '>= 2.6.0'

  spec.require_paths = ['lib']
  spec.files = Dir[
    'lib/**/*',
    'config/default.yml',
    '*.md'
  ]
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.metadata = {
    'changelog_uri' => 'https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://docs.rubocop.org/rubocop-rspec/',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_runtime_dependency 'rubocop', '~> 1.19'

  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.4'
  spec.add_development_dependency 'rubocop-performance', '~> 1.7'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'yard'
end
