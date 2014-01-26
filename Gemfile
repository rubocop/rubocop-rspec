source 'https://rubygems.org'

gemspec

# No gem would be complete without rake tasks.
gem 'rake', '~> 10.1'

group :test do
  # Our preferred unit testing library.
  gem 'rspec', '~> 2.14'

  # Cover all the things.
  gem 'simplecov', '~> 0.8'

  # Code coverage in badge form.
  gem 'coveralls', '~> 0.7'

  # Coverage and friends for rubinius
  gem 'rubinius-developer_tools', platform: :rbx
end

group :debugging do
  # Don't leave home without a debugger!
  gem 'debugger', '~> 1.6', :platforms => :mri
end
