---
name: Bug Report
about: Report an issue with RuboCop RSpec you've discovered.
---

*Be clear, concise and precise in your description of the problem.
Open an issue with a descriptive title and a summary in grammatically correct,
complete sentences.*

*Use the template below when reporting bugs. Please, make sure that
you're running the latest stable RuboCop RSpec and that the problem you're reporting
hasn't been reported (and potentially fixed) already.*

*Before filing the ticket you should replace all text above the horizontal
rule with your own words.*

*In the case of false positive or false negative, please add the
corresponding cop name.*

______________________________________________________________________

## Expected behavior

Describe here how you expected RuboCop RSpec to behave in this particular situation.

## Actual behavior

Describe here what actually happened.
Please use `rubocop --debug` when pasting rubocop output as it contains additional information.

## Steps to reproduce the problem

This is extremely important! Providing us with a reliable way to reproduce
a problem will expedite its solution.

## RuboCop RSpec version

Include the output of `rubocop -V` or `bundle exec rubocop -V` if using Bundler.
If you see extension cop versions (e.g. `rubocop-performance`, `rubocop-rake`, and others)
output by `rubocop -V`, include them as well. Here's an example:

```shell
$ [bundle exec] rubocop -V
1.67.0 (using Parser 3.3.5.0, rubocop-ast 1.32.3, analyzing as Ruby 2.7, running on ruby 3.4.0) [arm64-darwin23]
  - rubocop-performance 1.22.1
  - rubocop-rake 0.6.0
  - rubocop-rspec 3.1.0
```
