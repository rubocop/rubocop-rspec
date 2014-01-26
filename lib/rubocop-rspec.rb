# encoding: utf-8

require 'rubocop'

require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'

Rubocop::RSpec::Inject.defaults!

# We are housing ourselves directly into RuboCop's module structure. This is
# less than ideal, but until RuboCop directly supports plugins, we can avoid
# breaking too many assumptions.
require 'rubocop/cop/rspec/unit_spec_naming'
