# frozen_string_literal: true

eval_gemfile('common.rb')

# Use oldest RuboCop allowed by gemspec
gemspec = File.read('rubocop-rspec.gemspec')
version = gemspec[/ *spec.add_dependency 'rubocop'.*'>= ([0-9.]+)'/, 1]
gem 'rubocop', version
