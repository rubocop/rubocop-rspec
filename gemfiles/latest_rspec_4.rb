# frozen_string_literal: true

# Use latest RSpec 4 from `4-0-dev` branch
lines = File.readlines('gemfiles/common.rb')
lines.delete_if { |line| line.include?('rspec') }
eval_gemfile('common.rb', lines.join)

gem 'rspec', github: 'rspec/rspec', branch: '4-0-dev'
gem 'rspec-core', github: 'rspec/rspec', branch: '4-0-dev'
gem 'rspec-expectations', github: 'rspec/rspec', branch: '4-0-dev'
gem 'rspec-mocks', github: 'rspec/rspec', branch: '4-0-dev'
gem 'rspec-support', github: 'rspec/rspec', branch: '4-0-dev'
