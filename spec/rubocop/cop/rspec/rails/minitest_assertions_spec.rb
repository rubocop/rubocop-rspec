# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::MinitestAssertions, :config do
  it 'registers an offense when using `assert_equal`' do
    expect_offense(<<~RUBY)
      assert_equal(a, b)
      ^^^^^^^^^^^^^^^^^^ Use `expect(a).to eq(b)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(a).to eq(b)
    RUBY
  end

  it 'registers an offense when using `assert_equal` with no parentheses' do
    expect_offense(<<~RUBY)
      assert_equal a, b
      ^^^^^^^^^^^^^^^^^ Use `expect(a).to eq(b)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(a).to eq(b)
    RUBY
  end

  it 'registers an offense when using `assert_equal` with failure message' do
    expect_offense(<<~RUBY)
      assert_equal a, b, "must be equal"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to(eq(b), "must be equal")`.
    RUBY

    expect_correction(<<~RUBY)
      expect(a).to(eq(b), "must be equal")
    RUBY
  end

  it 'registers an offense when using `assert_equal` with ' \
     'multi-line arguments' do
    expect_offense(<<~RUBY)
      assert_equal(a,
      ^^^^^^^^^^^^^^^ Use `expect(a).to(eq(b), "must be equal")`.
                    b,
                    "must be equal")
    RUBY

    expect_correction(<<~RUBY)
      expect(a).to(eq(b), "must be equal")
    RUBY
  end

  it 'registers an offense when using `refute_equal`' do
    expect_offense(<<~RUBY)
      refute_equal a, b
      ^^^^^^^^^^^^^^^^^ Use `expect(a).not_to eq(b)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(a).not_to eq(b)
    RUBY
  end

  it 'does not register an offense when using `expect(a).to eq(b)`' do
    expect_no_offenses(<<~RUBY)
      expect(a).to eq(b)
    RUBY
  end

  it 'does not register an offense when using `expect(a).not_to eq(b)`' do
    expect_no_offenses(<<~RUBY)
      expect(a).not_to eq(b)
    RUBY
  end
end
