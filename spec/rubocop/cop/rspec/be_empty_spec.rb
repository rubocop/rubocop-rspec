# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::BeEmpty, :config do
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
