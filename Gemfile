# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rubocop', github: 'pirj/rubocop', branch: 'use-rubocop-dev'
gem 'rubocop-dev', github: 'pirj/rubocop-dev'

gemspec

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end
