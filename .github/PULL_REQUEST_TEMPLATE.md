**Replace this text with a summary of the changes in your PR.
The more detailed you are, the better.**

-----------------

Before submitting the PR make sure the following are checked:

* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Updated documentation (run `rake generate_cops_documentation`).
* [ ] Added an entry to the [Changelog](../blob/master/CHANGELOG.md) if the new code introduces user-observable changes.
* [ ] The build (`bundle exec rake`) is passing.

If you have created a new cop:
* [ ] Added the new cop to `config/default.yml`.
* [ ] The cop includes examples of good and bad code.
* [ ] You have tests for both code that should be reported and code that is good.
