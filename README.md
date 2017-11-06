# RuboCop RSpec

[![Join the chat at https://gitter.im/rubocop-rspec/Lobby](https://badges.gitter.im/rubocop-rspec/Lobby.svg)](https://gitter.im/rubocop-rspec/Lobby)
[![Gem Version](https://badge.fury.io/rb/rubocop-rspec.svg)](https://rubygems.org/gems/rubocop-rspec)
[![Dependency Status](https://gemnasium.com/backus/rubocop-rspec.svg)](https://gemnasium.com/backus/rubocop-rspec)
[![Build Status](https://secure.travis-ci.org/backus/rubocop-rspec.svg?branch=master)](http://travis-ci.org/backus/rubocop-rspec)
[![Coverage Status](https://codeclimate.com/github/backus/rubocop-rspec/badges/coverage.svg)](https://codeclimate.com/github/backus/rubocop-rspec/coverage)
[![Code Climate](https://codeclimate.com/github/backus/rubocop-rspec/badges/gpa.svg)](https://codeclimate.com/github/backus/rubocop-rspec)

RSpec-specific analysis for your projects, as an extension to
[RuboCop](https://github.com/bbatsov/rubocop).


## Installation

Just install the `rubocop-rspec` gem

```bash
gem install rubocop-rspec
```

or if you use bundler put this in your `Gemfile`

```
gem 'rubocop-rspec'
```


## Usage

You need to tell RuboCop to load the RSpec extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```
require: rubocop-rspec
```

Now you can run `rubocop` and it will automatically load the RuboCop RSpec
cops together with the standard cops.

### Command line

```bash
rubocop --require rubocop-rspec
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec'
end
```

### Code Climate

rubocop-rspec is available on Code Climate as part of the rubocop engine. [Learn More](https://codeclimate.com/changelog/55a433bbe30ba00852000fac).

## Inspecting files that don't end with `_spec.rb`

By default, `rubocop-rspec` only inspects code within paths ending in `_spec.rb` or including `spec/`. You can override this setting in your config file by specifying one or more patterns:

```yaml
# Inspect all files
AllCops:
  RSpec:
    Patterns:
    - '.+'
```

```yaml
# Inspect only files ending with `_test.rb`
AllCops:
  RSpec:
    Patterns:
    - '_test.rb$'
```

## The Cops

All cops are located under
[`lib/rubocop/cop/rspec`](lib/rubocop/cop/rspec), and contain
examples/documentation.

In your `.rubocop.yml`, you may treat the RSpec cops just like any other
cop. For example:

```yaml
RSpec/FilePath:
  Exclude:
    - spec/my_poorly_named_spec_file.rb
```


## Contributing

Checkout the [contribution guidelines](.github/CONTRIBUTING.md)

## License

`rubocop-rspec` is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for
the full text.
