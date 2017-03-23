RSpec.describe RuboCop::Cop::RSpec::LeakedConst do
  subject(:cop) { described_class.new }

  it 'finds a new named class defined in-line' do
    expect_violation(<<-RUBY)
      class Foo
      ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
      end
    RUBY
  end

  it 'finds a new named class defined inside of a let block' do
    expect_violation(<<-RUBY)
      let(:fake_class) do
        class Foo
        ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
        end
      end
    RUBY
  end

  it 'finds a new named class assigned to a variable' do
    expect_violation(<<-RUBY)
      fake_class = class Foo
                   ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
      end
    RUBY
  end

  it 'finds a new unnamed class inside of a let block' do
    expect_no_violations(<<-RUBY)
      let(:fake_class) { Class.new }
    RUBY
  end

  it 'finds a new unnamed class assigned to a variable' do
    expect_no_violations(<<-RUBY)
      fake_class = Class.new
    RUBY
  end

  it 'finds a new unnamed class using stub_const' do
    expect_no_violations(<<-RUBY)
      stub_const('Foo', Class.new)
    RUBY
  end
end
