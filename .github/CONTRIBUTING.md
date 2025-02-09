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

### Spell Checking

We are running [codespell](https://github.com/codespell-project/codespell) with [GitHub Actions](https://github.com/rubocop/rubocop-rspec/blob/master/.github/workflows/codespell.yml) to check spelling and
[codespell](https://pypi.org/project/codespell/).
`codespell` is written in [Python](https://www.python.org/) and you can run it with:

```console
$ codespell --ignore-words=.codespellignore
```

### Linting YAML files

We are running [yamllint](https://github.com/adrienverge/yamllint) for linting YAML files. This is also run by [GitHub Actions](https://github.com/rubocop/rubocop-rspec/blob/master/.github/workflows/linting.yml).
`yamllint` is written in [Python](https://www.python.org/) and you can run it with:

```console
$ yamllint .
```

### Formatting Markdown files

We are running [mdformat](https://github.com/executablebooks/mdformat) for formatting Markdown files. This is also run by [GitHub Actions](https://github.com/rubocop/rubocop-rspec/blob/master/.github/workflows/linting.yml).
`mdformat` is written in [Python](https://www.python.org/) and you can run it with:

```console
$ mdformat . --number
```

### Test Coverage - Line and Branch

We are using [Simplecov](https://github.com/colszowka/simplecov) to track test coverage.

It is included and reported when you run `bundle exec rake` or `bundle exec rspec`.

To view the coverage report, open the `coverage/index.html` file in your browser.

E.g. on macOS:

```console
$ open coverage/index.html
```

If you have unreachable lines, you can add `# :nocov` around those lines. The code itself or a comment should explain why the line is unreachable.

Example:

```ruby
# :nocov:
raise ArgumentError("Unsupported style :#{style}")
# :nocov:
```

This can happen for a few reasons, including:

1. When you handle config with a case statement and there is no else block.
2. When matching with a node pattern even when you handle all cases: all other node types will be excluded before reaching your handler, because the node pattern will not match them.

You will need full line and branch coverage to merge. This helps detect edge cases and prevent errors.

## Creating new cops

- Document examples of good and bad code in your cop.
- Add an entry to `config/default.yml`. It's an ordered list, so be sure to insert at the appropriate place.
- Run `bundle exec rake`. This will verify that the build passes as well as generate documentation and ensure that `config/default.yml` is up to date (don't forget to commit the documentation).
- Add tests for as many use cases as you can think of. Always add tests for both bad code that should register an offense and good code that should not.
- Common pitfalls:
  - If your cop inspects code outside of an example, check for false positives when similarly named variables are used inside of the example.
  - If your cop inspects code inside of an example, check that it works when the example is empty (empty `describe`, `it`, etc.).
