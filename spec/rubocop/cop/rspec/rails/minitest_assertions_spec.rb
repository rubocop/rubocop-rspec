# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::MinitestAssertions do
  it 'registers an offense when using `assert_equal`' do
    expect_offense(<<~RUBY)
      assert_equal(a, b)
      ^^^^^^^^^^^^^^^^^^ Use `expect(b).to eq(a)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(b).to eq(a)
    RUBY
  end

  it 'registers an offense when using `assert_equal` with no parentheses' do
    expect_offense(<<~RUBY)
      assert_equal a, b
      ^^^^^^^^^^^^^^^^^ Use `expect(b).to eq(a)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(b).to eq(a)
    RUBY
  end

  it 'registers an offense when using `assert_equal` with failure message' do
    expect_offense(<<~RUBY)
      assert_equal a, b, "must be equal"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(eq(a), "must be equal")`.
    RUBY

    expect_correction(<<~RUBY)
      expect(b).to(eq(a), "must be equal")
    RUBY
  end

  it 'registers an offense when using `assert_equal` with ' \
     'multi-line arguments' do
    expect_offense(<<~RUBY)
      assert_equal(a,
      ^^^^^^^^^^^^^^^ Use `expect(b).to(eq(a), "must be equal")`.
                    b,
                    "must be equal")
    RUBY

    expect_correction(<<~RUBY)
      expect(b).to(eq(a), "must be equal")
    RUBY
  end

  it 'registers an offense when using `refute_equal`' do
    expect_offense(<<~RUBY)
      refute_equal a, b
      ^^^^^^^^^^^^^^^^^ Use `expect(b).not_to eq(a)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(b).not_to eq(a)
    RUBY
  end

  it 'does not register an offense when using `expect(b).to eq(a)`' do
    expect_no_offenses(<<~RUBY)
      expect(b).to eq(a)
    RUBY
  end

  it 'does not register an offense when using `expect(b).not_to eq(a)`' do
    expect_no_offenses(<<~RUBY)
      expect(b).not_to eq(a)
    RUBY
  end
end
