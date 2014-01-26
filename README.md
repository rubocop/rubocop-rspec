RuboCop RSpec
=============

[![Gem Version](https://badge.fury.io/rb/rubocop-rspec.png)](https://rubygems.org/gems/rubocop-rspec)
[![Dependency Status](https://gemnasium.com/nevir/rubocop-rspec.png)](https://gemnasium.com/nevir/rubocop-rspec)
[![Build Status](https://secure.travis-ci.org/nevir/rubocop-rspec.png?branch=master)](http://travis-ci.org/nevir/rubocop-rspec)
[![Coverage Status](https://coveralls.io/repos/nevir/rubocop-rspec/badge.png?branch=master)](https://coveralls.io/r/nevir/rubocop-rspec)
[![Code Climate](https://codeclimate.com/github/nevir/rubocop-rspec.png)](https://codeclimate.com/github/nevir/rubocop-rspec)

RSpec-specific analysis for your projects, as an extension to
[RuboCop](https://github.com/bbatsov/rubocop).


Usage
-----

Add it to your bundle, or environment, and then you can load it via:

```bash
rubocop --require rubocop-rspec
```

or as part of your rubocop rake task:

```ruby
Rubocop::RakeTask.new(:style) do |task|
  task.requires << 'rubocop-rspec'
end
```


License
-------

`rubocop-rspec` is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for
the full text.
