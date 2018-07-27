# FactoryBot

## FactoryBot/AttributeDefinedStatically

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Always declare attribute values as blocks.

### Examples

```ruby
# bad
kind [:active, :rejected].sample

# good
kind { [:active, :rejected].sample }

# bad
closed_at 1.day.from_now

# good
closed_at { 1.day.from_now }

# bad
count 1

# good
count { 1 }
```

### References

* [http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/AttributeDefinedStatically](http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/AttributeDefinedStatically)

## FactoryBot/CreateList

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for create_list usage.

This cop can be configured using the `EnforcedStyle` option

### Examples

#### `EnforcedStyle: create_list`

```ruby
# bad
3.times { create :user }

# good
create_list :user, 3

# good
3.times { |n| create :user, created_at: n.months.ago }
```
#### `EnforcedStyle: n_times`

```ruby
# bad
create_list :user, 3

# good
3.times { create :user }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `create_list` | `create_list`, `n_times`

### References

* [http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/CreateList](http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/CreateList)

## FactoryBot/DynamicAttributeDefinedStatically

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

Prefer declaring dynamic attribute values in a block.

### Examples

```ruby
# bad
kind [:active, :rejected].sample

# good
kind { [:active, :rejected].sample }

# bad
closed_at 1.day.from_now

# good
closed_at { 1.day.from_now }
```

### References

* [http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/DynamicAttributeDefinedStatically](http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/DynamicAttributeDefinedStatically)

## FactoryBot/StaticAttributeDefinedDynamically

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

Prefer declaring static attribute values without a block.

### Examples

```ruby
# bad
kind { :static }

# good
kind :static

# bad
comments_count { 0 }

# good
comments_count 0

# bad
type { User::MAGIC }

# good
type User::MAGIC
```

### References

* [http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/StaticAttributeDefinedDynamically](http://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/FactoryBot/StaticAttributeDefinedDynamically)
