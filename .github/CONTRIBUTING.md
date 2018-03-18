# Contributing

If you discover issues, have ideas for improvements or new features,
please report them to the [issue tracker][1] of the repository or
submit a pull request. Please, try to follow these guidelines when you
do so.

## Issue reporting

* Check that the issue has not already been reported.
* Check that the issue has not already been fixed in the latest code
  (a.k.a. `master`).
* Be clear, concise and precise in your description of the problem.
* Open an issue with a descriptive title and a summary in grammatically correct,
  complete sentences.
* Report the versions of `rubocop-rspec`, as well as the output of `rubocop -V`
* Include any relevant code to the issue summary.

## Pull requests
1. Fork the project.
2. Create a feature branch.
3. Make sure to add tests.
4. Make sure the test suite is passing (run `rake`).
5. Add [Changelog](../blob/master/CHANGELOG.md) entry.
6. Commit your changes.
7. Push to the branch.
8. Create new Pull Request.

## Creating new cops
There are some steps you have to follow when you add new cops:
* Add an entry to `config/default.yml`. It's ordered list, make sure to follow the order.
* The description of the cop in the code should match the one in config. `bin/build_config` copies the description from the cop to config.
* The cop should include examples of good and bad code.
* Generate documentation for the cop using `rake generate_cops_documentation`.
* Add tests for as much use cases as you can think of. Always add tests for both code that should be reported and good code that should pass.
* Some common pitfalls:
** If you are writing cop inspecting code outside of an example, check for false positive when similarly named variables are used inside of the example.
** If your cop is inspecting code inside an example, check that it works when the example is empty (empty `describe`, `it`, etc.).

[1]: https://github.com/backus/rubocop-rspec/issues
