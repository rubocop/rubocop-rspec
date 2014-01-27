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
end

group :debugging do
  # Don't leave home without a debugger!
  gem 'debugger', '~> 1.6', :platforms => :mri
end

# Rubinius doesn't bundle up everything in the regular standard library; get the
# heaver things we rely on.
group :rubinius do
  # Fill in the standard library.
  gem 'rubysl', '~> 2.0', platform: :rbx

  # Coverage and friends.
  gem 'rubinius-developer_tools', '~> 2.0', platform: :rbx

  # Ruby parser/generator.
  gem 'racc', '~> 1.4', platform: :rbx
end
