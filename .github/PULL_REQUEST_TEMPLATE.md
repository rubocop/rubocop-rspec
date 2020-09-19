**Replace this text with a summary of the changes in your PR. The more detailed you are, the better.**

---

Before submitting the PR make sure the following are checked:

* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Updated documentation.
* [ ] Added an entry to the `CHANGELOG.md` if the new code introduces user-observable changes.
* [ ] The build (`bundle exec rake`) passes (be sure to run this locally, since it may produce updated documentation that you will need to commit).

If you have created a new cop:

* [ ] Added the new cop to `config/default.yml`.
* [ ] The cop is configured as `Enabled: pending` in `config/default.yml`.
* [ ] The cop documents examples of good and bad code.
* [ ] The tests assert both that bad code is reported and that good code is not reported.
* [ ] Set `VersionAdded` in `default/config.yml` to the next minor version.

If you have modified an existing cop's configuration options:

* [ ] Set `VersionChanged` in `config/default.yml` to the next major version.
