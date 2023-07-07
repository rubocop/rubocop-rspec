# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'bump'
gem 'danger'
gem 'rack'
gem 'rake'
gem 'rspec', '~> 3.11'
gem 'rubocop-performance', '~> 1.7'
gem 'rubocop-rake', '~> 0.6'
gem 'simplecov', '>= 0.19'
gem 'yard'

local_gemfile = 'Gemfile.local'
eval_gemfile(local_gemfile) if File.exist?(local_gemfile)
