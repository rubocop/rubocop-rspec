# encoding: utf-8

require 'rubocop'

require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'

Rubocop::RSpec::Inject.defaults!

require 'rubocop/cop/top_level_describe'

# cops
require 'rubocop/cop/rspec_described_class'
require 'rubocop/cop/rspec_described_method'
require 'rubocop/cop/rspec_description'
require 'rubocop/cop/rspec_file_name'
