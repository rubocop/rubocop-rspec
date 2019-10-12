# Capybara

## Capybara/CurrentPathExpectation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that no expectations are set on Capybara's `current_path`.

The `have_current_path` matcher (https://www.rubydoc.info/github/
teamcapybara/capybara/master/Capybara/RSpecMatchers#have_current_path-
instance_method) should be used on `page` to set expectations on
Capybara's current path, since it uses Capybara's waiting
functionality (https://github.com/teamcapybara/capybara/blob/master/
README.md#asynchronous-javascript-ajax-and-friends) which ensures that
preceding actions (like `click_link`) have completed.

### Examples

```ruby
# bad
expect(current_path).to eq('/callback')
expect(page.current_path).to match(/widgets/)

# good
expect(page).to have_current_path("/callback")
expect(page).to have_current_path(/widgets/)
```

### References

* [https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Capybara/CurrentPathExpectation](https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Capybara/CurrentPathExpectation)

## Capybara/FeatureMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for consistent method usage in feature specs.

By default, the cop disables all Capybara-specific methods that have
the same native RSpec method (e.g. are just aliases). Some teams
however may prefer using some of the Capybara methods (like `feature`)
to make it obvious that the test uses Capybara, while still disable
the rest of the methods, like `given` (alias for `let`), `background`
(alias for `before`), etc. You can configure which of the methods to
be enabled by using the EnabledMethods configuration option.

### Examples

```ruby
# bad
feature 'User logs in' do
  given(:user) { User.new }

  background do
    visit new_session_path
  end

  scenario 'with OAuth' do
    # ...
  end
end

# good
describe 'User logs in' do
  let(:user) { User.new }

  before do
    visit new_session_path
  end

  it 'with OAuth' do
    # ...
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnabledMethods | `[]` | Array

### References

* [https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Capybara/FeatureMethods](https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Capybara/FeatureMethods)
