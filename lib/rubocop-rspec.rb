# encoding: utf-8

require 'rubocop'

require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'
require 'rubocop/rspec/top_level_describe'

Rubocop::RSpec::Inject.defaults!

# cops
require 'rubocop/cop/rspec_describe_class'
require 'rubocop/cop/rspec_describe_method'
require 'rubocop/cop/rspec_described_class'
require 'rubocop/cop/rspec_example_wording'
require 'rubocop/cop/rspec_file_name'
require 'rubocop/cop/rspec_instance_variable'
require 'rubocop/cop/rspec_multiple_describes'
