# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::NegatedExpectation, :config do
  it 'registers an offense when using redundant negation with `.to`' do
    expect_offense(<<~RUBY)
      !expect(foo).to be_valid
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(...).not_to` instead of `!expect(...).to`
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).not_to be_valid
    RUBY
  end

  it 'registers an offense when using redundant negation with `.not_to`' do
    expect_offense(<<~RUBY)
      !expect(foo).not_to be_valid
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(...).to` instead of `!expect(...).not_to`
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to be_valid
    RUBY
  end

  it 'registers an offense when using redundant negation with `.to_not`' do
    expect_offense(<<~RUBY)
      !expect(foo).to_not be_valid
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(...).to` instead of `!expect(...).to_not`
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to be_valid
    RUBY
  end

  it 'does not register an offense when without redundant negation' do
    expect_no_offenses(<<~RUBY)
      expect(foo).not_to be_valid
    RUBY
  end
end
