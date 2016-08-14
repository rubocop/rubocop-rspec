require 'rubocop'

require 'rubocop/rspec/support'

if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

module SpecHelper
  ROOT = Pathname.new(__dir__).parent.freeze
end

spec_helper_glob = File.expand_path('{support,shared}/*.rb', __dir__)
Dir.glob(spec_helper_glob).map(&method(:require))

RSpec.configure do |config|
  config.order = :random

  # Define spec metadata for all rspec cop spec files
  cop_specs = 'spec/rubocop/cop/rspec/'
  config.define_derived_metadata(file_path: /\b#{cop_specs}/) do |metadata|
    # Attach metadata that signals the specified code is for an RSpec only cop
    metadata[:rspec_cop] = true
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect # Disable `should`
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect # Disable `should_receive` and `stub`
  end

  config.include(ExpectViolation)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubocop-rspec'
