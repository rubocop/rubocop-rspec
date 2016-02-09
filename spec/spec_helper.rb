# encoding: utf-8

require 'rubocop'

rubocop_path = File.join(File.dirname(__FILE__), '../vendor/rubocop')

unless File.directory?(rubocop_path)
  raise "Can't run specs without a local RuboCop checkout. Look in the README."
end

Dir["#{rubocop_path}/spec/support/**/*.rb"].each { |f| require f }

if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

RSpec.configure do |config|
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect # Disable `should`
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect # Disable `should_receive` and `stub`
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubocop-rspec'
