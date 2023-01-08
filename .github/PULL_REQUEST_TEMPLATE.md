**Replace this text with a summary of the changes in your PR. The more detailed you are, the better.**

______________________________________________________________________

Before submitting the PR make sure the following are checked:

- [ ] Feature branch is up-to-date with `master` (if not - rebase it).
- [ ] Squashed related commits together.
- [ ] Added tests.
- [ ] Updated documentation.
- [ ] Added an entry (file) to the [changelog folder](https://github.com/rubocop/rubocop-committee/blob/master/changelog/) named `{change_type}_{change_description}.md` if the new code introduces user-observable changes. See [changelog entry format](https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format) for details.
- [ ] The build (`bundle exec rake`) passes (be sure to run this locally, since it may produce updated documentation that you will need to commit).

If you have created a new cop:

- [ ] Added the new cop to `config/default.yml`.
- [ ] The cop is configured as `Enabled: pending` in `config/default.yml`.
- [ ] The cop is configured as `Enabled: true` in `.rubocop.yml`.
- [ ] The cop documents examples of good and bad code.
- [ ] The tests assert both that bad code is reported and that good code is not reported.
- [ ] Set `VersionAdded: "<<next>>"` in `default/config.yml`.

If you have modified an existing cop's configuration options:

- [ ] Set `VersionChanged: "<<next>>"` in `config/default.yml`.
