RSpec.describe RuboCop::Cop::RSpec::DescribeSymbol do
  subject(:cop) { described_class.new }

  it 'flags violations for `describe :symbol`' do
    expect_violation(<<-RUBY)
      describe(:some_method) { }
               ^^^^^^^^^^^^ Avoid describing symbols.
    RUBY
  end

  it 'flags violations for `describe :symbol` with multiple arguments' do
    expect_violation(<<-RUBY)
      describe(:some_method, "description") { }
               ^^^^^^^^^^^^ Avoid describing symbols.
    RUBY
  end

  it 'flags violations for `RSpec.describe :symbol`' do
    expect_violation(<<-RUBY)
      RSpec.describe(:some_method, "description") { }
                     ^^^^^^^^^^^^ Avoid describing symbols.
    RUBY
  end

  it 'flags violations for a nested `describe`' do
    expect_violation(<<-RUBY)
      RSpec.describe Foo do
        describe :to_s do
                 ^^^^^ Avoid describing symbols.
        end
      end
    RUBY
  end

  it 'does not flag non-Symbol arguments' do
    expect_no_violations('describe("#some_method") { }')
  end

  it 'does not flag `context :symbol`' do
    expect_no_violations('context(:some_method) { }')
  end
end
