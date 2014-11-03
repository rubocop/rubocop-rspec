# Change log

## 1.2.1

* Add `RSpec::VerifiedDoubles` cop. ([@andyw8][])

## 1.2.0

* Drop support of ruby `1.9.2`. ([@geniou][])
* Update to RuboCop `~> 0.24`. ([@geniou][])
* Add `autocorrect` to `RSpec::ExampleWording`. This experimental - use with care and check the changes. ([@geniou][])
* Fix config loader debug output. ([@geniou][])
* Rename `FileName` cop to `FilePath` as a workaround - see [#19](https://github.com/nevir/rubocop-rspec/issues/19). ([@geniou][])

## 1.1.0

* Add `autocorrect` to `RSpec::DescribedClass` cop. ([@geniou][])

## 1.0.1

* Add `config` folder to gemspec. ([@pstengel][])

## 1.0.rc3

* Update to RuboCop `>= 0.23`. ([@geniou][])
* Add configuration option for `CustomTransformation` to `FileName` cop. ([@geniou][])

## 1.0.rc2

* Gem is no longer 20MB (sorry!). ([@nevir][])
* `RspecFileName` cop allows for method specs to organized into directories by class and type. ([@nevir][])

## 1.0.rc1

* Update code to work with rubocop `>= 0.19`. ([@geniou][])
* Split `UnitSpecNaming` cop into `RSpecDescribeClass`, `RSpecDescribeMethod` and `RSpecFileName` and enabled them all by default. ([@geniou][])
* Add `RSpecExampleWording` cop to prevent to use of should at the beginning of the spec description. ([@geniou][])
* Fix `RSpecFileName` cop for non-class specs. ([@geniou][])
* Adapt `RSpecFileName` cop to commen naming convention and skip spec with multiple top level describes. ([@geniou][])
* Add `RSpecMultipleDescribes` cop to check for multiple top level describes. ([@geniou][])
* Add `RSpecDescribedClass` to promote the use of `described_class`. ([@geniou][])
* Add `RSpecInstanceVariable` cop to check for the usage of instance variables. ([@geniou][])

<!-- Contributors -->

[@andyw8]: https://github.com/andyw8
[@geniou]: https://github.com/geniou
[@nevir]: https://github.com/nevir
[@pstengel]: https://github.com/pstengel
