# Rails

## Rails/HttpStatus

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

Enforces use of symbolic or numeric value to describe HTTP status.

### Examples

#### `EnforcedStyle: symbolic` (default)

```ruby
# bad
it { is_expected.to have_http_status 200 }
it { is_expected.to have_http_status 404 }

# good
it { is_expected.to have_http_status :ok }
it { is_expected.to have_http_status :not_found }
it { is_expected.to have_http_status :success }
it { is_expected.to have_http_status :error }
```
#### `EnforcedStyle: numeric`

```ruby
# bad
it { is_expected.to have_http_status :ok }
it { is_expected.to have_http_status :not_found }

# good
it { is_expected.to have_http_status 200 }
it { is_expected.to have_http_status 404 }
it { is_expected.to have_http_status :success }
it { is_expected.to have_http_status :error }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `symbolic` | `numeric`, `symbolic`

### References

* [http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Rails/HttpStatus](http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Rails/HttpStatus)
