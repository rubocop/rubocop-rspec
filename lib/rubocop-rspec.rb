# encoding: utf-8

require 'rubocop'

require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'

Rubocop::RSpec::Inject.defaults!

require 'rubocop/cop/top_level_describe'

# cops
require 'rubocop/cop/rspec_describe_class'
require 'rubocop/cop/rspec_describe_method'
require 'rubocop/cop/rspec_described_class'
require 'rubocop/cop/rspec_example_wording'
require 'rubocop/cop/rspec_file_name'
require 'rubocop/cop/rspec_multiple_describes'
