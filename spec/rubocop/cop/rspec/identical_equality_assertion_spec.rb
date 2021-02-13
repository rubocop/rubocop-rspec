# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IdenticalEqualityAssertion do
  it 'registers an offense when using identical expressions with `eq`' do
    expect_offense(<<~RUBY)
      expect(foo.bar).to eq(foo.bar)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Identical expressions on both sides of the equality may indicate a flawed test.
    RUBY
  end

  it 'registers an offense when using identical expressions with `eql`' do
    expect_offense(<<~RUBY)
      expect(foo.bar.baz).to eql(foo.bar.baz)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Identical expressions on both sides of the equality may indicate a flawed test.
    RUBY
  end

  it 'registers an offense for trivial constants' do
    expect_offense(<<~RUBY)
      expect(42).to eq(42)
      ^^^^^^^^^^^^^^^^^^^^ Identical expressions on both sides of the equality may indicate a flawed test.
    RUBY
  end

  it 'registers an offense for complex constants' do
    expect_offense(<<~RUBY)
      expect({a: 1, b: :b}).to eql({a: 1, b: :b})
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Identical expressions on both sides of the equality may indicate a flawed test.
    RUBY
  end

  it 'registers an offense for identical expression with be' do
    expect_offense(<<~RUBY)
      expect(foo.bar).to be(foo.bar)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Identical expressions on both sides of the equality may indicate a flawed test.
    RUBY
  end

  it 'registers an offense for identical expression with be ==' do
    expect_offense(<<~RUBY)
      expect(foo.bar).to be == foo.bar
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Identical expressions on both sides of the equality may indicate a flawed test.
    RUBY
  end

  it 'does not register offense for different expressions' do
    expect_no_offenses(<<~RUBY)
      expect(foo.bar).to eq(bar.foo)
    RUBY
  end

  it 'checks for whole expression' do
    expect_no_offenses(<<~RUBY)
      expect(Foo.new(1).foo).to eql(Foo.new(2).bar)
    RUBY
  end
end
