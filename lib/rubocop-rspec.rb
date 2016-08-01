require 'rubocop'

require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'
require 'rubocop/rspec/top_level_describe'
require 'rubocop/rspec/wording'
require 'rubocop/rspec/util'

RuboCop::RSpec::Inject.defaults!

# cops
require 'rubocop/cop/rspec/any_instance'
require 'rubocop/cop/rspec/describe_class'
require 'rubocop/cop/rspec/describe_method'
require 'rubocop/cop/rspec/described_class'
require 'rubocop/cop/rspec/example_wording'
require 'rubocop/cop/rspec/file_path'
require 'rubocop/cop/rspec/focus'
require 'rubocop/cop/rspec/instance_variable'
require 'rubocop/cop/rspec/example_length'
require 'rubocop/cop/rspec/multiple_describes'
require 'rubocop/cop/rspec/not_to_not'
require 'rubocop/cop/rspec/verified_doubles'
