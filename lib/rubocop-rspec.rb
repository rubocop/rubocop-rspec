# encoding: utf-8

require 'rubocop'

# TODO: workaround for RuboCop renaming
Rubocop = RuboCop

require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'
require 'rubocop/rspec/top_level_describe'

Rubocop::RSpec::Inject.defaults!

# cops
require 'rubocop/cop/rspec/describe_class'
require 'rubocop/cop/rspec/describe_method'
require 'rubocop/cop/rspec/described_class'
require 'rubocop/cop/rspec/example_wording'
require 'rubocop/cop/rspec/file_name'
require 'rubocop/cop/rspec/instance_variable'
require 'rubocop/cop/rspec/multiple_describes'
