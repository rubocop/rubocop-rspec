# Change log

## 1.0.rc1

* Update code to work with rubocop >= 0.19 ([@geniou][])
* Split `UnitSpecNaming` cop into `RSpecDescribeClass`,
  `RSpecDescribeMethod` and `RSpecFileName` and enabled them all by
  default. ([@geniou][])
* Add `RSpecExampleWording` cop to prevent to use of should at the
  beginning of the spec description. ([@geniou][])
* Fix `RSpecFileName` cop for non-class specs. ([@geniou][])
* Adapt `RSpecFileName` cop to commen naming convention and skip spec
  with multiple top level describes. ([@geniou][])
* Add `RSpecMultipleDescribes` cop to check for multiple top level
  describes. ([@geniou][])
* Add `RSpecDescribedClass` to promote the use of `described_class`.
  ([@geniou][])
* Add `RSpecInstanceVariable` cop to check for the usage of instance
  variables. ([@geniou][])

<!-- Contributors -->

[@geniou]: https://github.com/geniou
[@nevir]: https://github.com/nevir
