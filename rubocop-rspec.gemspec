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
  spec.homepage = 'https://github.com/rubocop-hq/rubocop-rspec'
  spec.authors = ['John Backus', 'Ian MacLeod', 'Nils Gemeinhardt']
  spec.email = [
    'johncbackus@gmail.com',
    'ian@nevir.net',
    'git@nilsgemeinhardt.de'
  ]
  spec.licenses = ['MIT']

  spec.version = RuboCop::RSpec::Version::STRING
  spec.platform = Gem::Platform::RUBY

  # RuboCop RSpec does require Ruby 2.3+ to run. In development and on CI,
  # RuboCop RSpec flexibly depends on RuboCop, with a minimum version of
  # 0.68. RuboCop only supports Ruby 2.4+ as a TargetRubyVersion starting
  # from version 0.82, while its version 0.68 does support Ruby 2.3. We
  # keep support for codebases that use Ruby 2.3 and RuboCop pre-0.82.
  spec.required_ruby_version =
    '>= 2.3.0' # rubocop:disable Gemspec/RequiredRubyVersion

  spec.require_paths = ['lib']
  spec.files = Dir[
    'lib/**/*',
    'config/default.yml',
    '*.md'
  ]
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.metadata = {
    'changelog_uri' => 'https://github.com/rubocop-hq/rubocop-rspec/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://rubocop-rspec.readthedocs.io/'
  }

  spec.add_runtime_dependency 'rubocop', '>= 0.68.1'

  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.4'
  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  spec.add_development_dependency 'simplecov', '< 0.18'
  spec.add_development_dependency 'yard'
end
