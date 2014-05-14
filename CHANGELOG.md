# Change log

## master (unreleased)

* Update code to work with rubocop >= 0.19 ([@geniou][])
* Split `UnitSpecNaming` into `RSpecDescribedClass`, `RSpecDescribedMethod` and
  `RSpecFileName` and enabled them all by default ([@geniou][])
* Add `RSpecDescription` cop to prevent to use of should in spec
  description. ([@geniou][])
* `RSpecFileName` cop for non-class specs ([@geniou][])
* Adapt `RSpecFileName` cop to commen naming convention and skip spec
  with multiple top level describes. ([@geniou][])
* Add `RSpecMultipleDescribes` to check for multiple top level
  describes. ([@geniou][])

[@geniou]: https://github.com/geniou
