# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DescribeSymbol do
  it 'flags offenses for `describe :symbol`' do
    expect_offense(<<~RUBY)
      describe(:some_method) { }
               ^^^^^^^^^^^^ Avoid describing symbols.
    RUBY
  end

  it 'flags offenses for `describe :symbol` with multiple arguments' do
    expect_offense(<<~RUBY)
      describe(:some_method, "description") { }
               ^^^^^^^^^^^^ Avoid describing symbols.
    RUBY
  end

  it 'flags offenses for `RSpec.describe :symbol`' do
    expect_offense(<<~RUBY)
      RSpec.describe(:some_method, "description") { }
                     ^^^^^^^^^^^^ Avoid describing symbols.
    RUBY
  end

  it 'flags offenses for a nested `describe`' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        describe :to_s do
                 ^^^^^ Avoid describing symbols.
        end
      end
    RUBY
  end

  it 'does not flag non-Symbol arguments' do
    expect_no_offenses('describe("#some_method") { }')
  end

  it 'does not flag `context :symbol`' do
    expect_no_offenses('context(:some_method) { }')
  end
end
