# frozen_string_literal: true

source 'https://rubygems.org'

gemspec path: '..'

gem 'bump'
gem 'rack'
gem 'rake'
gem 'rspec', '~> 3.11'
gem 'rubocop-performance', '~> 1.24'
gem 'rubocop-rake', '~> 0.7'
gem 'simplecov', '>= 0.19'
gem 'yard'

# FIXME: Remove when the next prism version is released.
if RUBY_VERSION < '3.0' || RUBY_ENGINE == 'jruby'
  gem 'prism', '!= 1.5.0', '!= 1.5.1'
end
