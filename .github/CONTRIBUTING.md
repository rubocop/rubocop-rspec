# Contributing

If you encounter problems or have ideas for improvements or new features, please report them to the [issue tracker](https://github.com/rubocop/rubocop-rspec/issues) or submit a pull request. Please, try to follow these guidelines when you do so.

## Issue reporting

- Check that the issue has not already been reported.
- Check that the issue has not already been fixed in the latest code (a.k.a. `master`).
- Check if the issue is a non-goal of RuboCop RSpec.
- Be clear, concise, and precise in your description of the problem.
- Open an issue with a descriptive title and a summary in grammatically correct, complete sentences.
- Report the versions of `rubocop-rspec`, as well as the output of `rubocop -V`.
- Include any relevant code to the issue summary.

## Pull requests

1. Fork the project.
2. Create a feature branch.
3. Make sure to add tests.
4. Make sure the test suite passes (run `rake`).
5. Add a [changelog](https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md) entry.
6. Commit your changes.
7. Push to the branch.
8. Create new Pull Request.

## Creating new cops

- Document examples of good and bad code in your cop.
- Add an entry to `config/default.yml`. It's an ordered list, so be sure to insert at the appropriate place.
- Run `bundle exec rake`. This will verify that the build passes as well as generate documentation and ensure that `config/default.yml` is up to date (don't forget to commit the documentation).
- Add tests for as many use cases as you can think of. Always add tests for both bad code that should register an offense and good code that should not.
- Common pitfalls:
  - If your cop inspects code outside of an example, check for false positives when similarly named variables are used inside of the example.
  - If your cop inspects code inside of an example, check that it works when the example is empty (empty `describe`, `it`, etc.).
