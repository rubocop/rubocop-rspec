# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rack'
gem 'rake'
gem 'rspec', '~> 3.11'
gem 'rubocop-performance', '~> 1.7'
gem 'rubocop-rake', '~> 0.6'
gem 'yard'

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end
