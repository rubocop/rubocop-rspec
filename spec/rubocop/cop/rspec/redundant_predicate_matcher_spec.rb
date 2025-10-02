# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RedundantPredicateMatcher do
  it 'registers an offense when using `be_all`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_all be_odd
                     ^^^^^^^^^^^^^ Use `all` instead of `be_all`.
      expect(foo).to be_all(expected_foo_element_value)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `all` instead of `be_all`.
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense when using `be_all` with `{}`' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to be_all { |bar| bar == baz }
    RUBY
  end

  it 'does not register an offense when using `be_all` with `do ... end`' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to be_all do |bar|
        bar == baz
      end
    RUBY
  end

  it 'does not register an offense when using `be_all` without send' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to be_all(false)
      expect(foo).to be_all(1)
    RUBY
  end

  it 'does not register an offense when using `be_match` without argument' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to be_match
    RUBY
  end

  it 'registers an offense when using `be_cover`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_cover(bar, baz)
                     ^^^^^^^^^^^^^^^^^^ Use `cover` instead of `be_cover`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to cover(bar, baz)
    RUBY
  end

  it 'registers an offense when using `be_end_with`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_end_with('?')
                     ^^^^^^^^^^^^^^^^ Use `end_with` instead of `be_end_with`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to end_with('?')
    RUBY
  end

  it 'registers an offense when using `be_eql`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_eql(bar)
                     ^^^^^^^^^^^ Use `eql` instead of `be_eql`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to eql(bar)
    RUBY
  end

  it 'registers an offense when using `be_equal`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_equal(bar)
                     ^^^^^^^^^^^^^ Use `equal` instead of `be_equal`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to equal(bar)
    RUBY
  end

  it 'registers an offense when using `be_exist`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_exist("bar.txt")
                     ^^^^^^^^^^^^^^^^^^^ Use `exist` instead of `be_exist`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to exist("bar.txt")
    RUBY
  end

  it 'registers an offense when using `be_exists`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_exists("bar.txt")
                     ^^^^^^^^^^^^^^^^^^^^ Use `exist` instead of `be_exists`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to exist("bar.txt")
    RUBY
  end

  it 'registers an offense when using `be_include`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_include(bar, baz)
                     ^^^^^^^^^^^^^^^^^^^^ Use `include` instead of `be_include`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to include(bar, baz)
    RUBY
  end

  it 'registers an offense when using `be_match`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_match(/bar/)
                     ^^^^^^^^^^^^^^^ Use `match` instead of `be_match`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to match(/bar/)
    RUBY
  end

  it 'registers an offense when using `be_respond_to`' do
    expect_offense(<<~RUBY)
      expect("string").to be_respond_to(:length)
                          ^^^^^^^^^^^^^^^^^^^^^^ Use `respond_to` instead of `be_respond_to`.
    RUBY

    expect_correction(<<~RUBY)
      expect("string").to respond_to(:length)
    RUBY
  end

  it 'registers an offense when using `be_start_with`' do
    expect_offense(<<~RUBY)
      expect(foo).to be_start_with("A")
                     ^^^^^^^^^^^^^^^^^^ Use `start_with` instead of `be_start_with`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to start_with("A")
    RUBY
  end

  it 'does not register an offense when using built-in matcher' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to all(bar)
      expect(foo).to cover(bar)
      expect(foo).to end_with(bar)
    RUBY
  end

  context 'when `SupportedMethods` is customized' do
    let(:cop_config) do
      { 'SupportedMethods' => { 'be_include' => 'include' } }
    end

    it 'registers an offense when using `be_include`' do
      expect_offense(<<~RUBY)
        expect(foo).to be_include(bar, baz)
                       ^^^^^^^^^^^^^^^^^^^^ Use `include` instead of `be_include`.
      RUBY

      expect_correction(<<~RUBY)
        expect(foo).to include(bar, baz)
      RUBY
    end

    it 'does not register an offense when using `be_exist`' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_exist("bar.txt")
      RUBY
    end
  end
end
