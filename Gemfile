source 'https://rubygems.org'

gemspec

gem 'rubocop', '< 0.60.0'

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end
