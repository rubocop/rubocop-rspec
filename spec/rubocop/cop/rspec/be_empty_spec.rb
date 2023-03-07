# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::BeEmpty, :config do
  it 'registers an offense when using `expect(array.empty?).to be true`' do
    expect_offense(<<~RUBY)
      expect(array.empty?).to be true
                              ^^^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array.empty?).to be_truthy`' do
    expect_offense(<<~RUBY)
      expect(array.empty?).to be_truthy
                              ^^^^^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array.size).to eq(0)`' do
    expect_offense(<<~RUBY)
      expect(array.size).to eq(0)
                            ^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array.length).to eq(0)`' do
    expect_offense(<<~RUBY)
      expect(array.length).to eq(0)
                              ^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array.count).to eq(0)`' do
    expect_offense(<<~RUBY)
      expect(array.count).to eq(0)
                             ^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array).to eq([])`' do
    expect_offense(<<~RUBY)
      expect(array).to eq([])
                       ^^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array).to eql([])`' do
    expect_offense(<<~RUBY)
      expect(array).to eql([])
                       ^^^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array).to contain_exactly`' do
    expect_offense(<<~RUBY)
      expect(array).to contain_exactly
                       ^^^^^^^^^^^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'registers an offense when using `expect(array).to match_array([])`' do
    expect_offense(<<~RUBY)
      expect(array).to match_array([])
                       ^^^^^^^^^^^^^^^ Use `be_empty` matchers for checking an empty array.
    RUBY

    expect_correction(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end

  it 'does not register an offense when using `expect(array).to be_empty`' do
    expect_no_offenses(<<~RUBY)
      expect(array).to be_empty
    RUBY
  end
end
