source 'https://rubygems.org'

gemspec

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'simplecov',                 '~> 0.12.0', require: false
end

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end
