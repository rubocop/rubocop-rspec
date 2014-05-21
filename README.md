# RuboCop RSpec

[![Gem Version](https://badge.fury.io/rb/rubocop-rspec.png)](https://rubygems.org/gems/rubocop-rspec)
[![Dependency Status](https://gemnasium.com/nevir/rubocop-rspec.png)](https://gemnasium.com/nevir/rubocop-rspec)
[![Build Status](https://secure.travis-ci.org/nevir/rubocop-rspec.png?branch=master)](http://travis-ci.org/nevir/rubocop-rspec)
[![Coverage Status](https://coveralls.io/repos/nevir/rubocop-rspec/badge.png?branch=master)](https://coveralls.io/r/nevir/rubocop-rspec)
[![Code Climate](https://codeclimate.com/github/nevir/rubocop-rspec.png)](https://codeclimate.com/github/nevir/rubocop-rspec)

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

Put this into you `.rubocop.yml`. **For now this is only supported in the
github version of RuboCop.**

```
require: rubocop-rspec
```

Now you can run `rubocop` and it will autmaticly load the RuboCop RSpec
cops together with the standard cops.

### Command line

```bash
rubocop --require rubocop-rspec
```

### Rake task

```ruby
Rubocop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec'
end
```


## The Cops

**WARNING: Cop names are under flux and will likely change in the near future.**
We're hoping to
[introduce namespaces](https://github.com/bbatsov/rubocop/issues/1097) into the mix.

All cops are located under [`lib/rubocop/cop`](lib/rubocop/cop), and contain
examples/documentation.

In your `.rubocop.yml`, you may treat the RSpec cops just like any other cop.
For example:

```yaml
RSpecFileName:
  Exclude:
  - spec/my_poorly_named_spec_file.rb
```


## License

`rubocop-rspec` is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for
the full text.
