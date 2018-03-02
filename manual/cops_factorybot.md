# FactoryBot

## FactoryBot/DynamicAttributeDefinedStatically

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

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
Enabled | Yes

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
