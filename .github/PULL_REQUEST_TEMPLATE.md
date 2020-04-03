**Replace this text with a summary of the changes in your PR. The more detailed you are, the better.**

---

Before submitting the PR make sure the following are checked:

* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Updated documentation.
* [ ] Added an entry to the [changelog](https://github.com/rubocop-hq/rubocop-rspec/blob/master/CHANGELOG.md) if the new code introduces user-observable changes.
* [ ] The build (`bundle exec rake`) passes (be sure to run this locally, since it may produce updated documentation that you will need to commit).

If you have created a new cop:

* [ ] Added the new cop to `config/default.yml`.
* [ ] The cop documents examples of good and bad code.
* [ ] The tests assert both that bad code is reported and that good code is not reported.
