# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::CurrentPathExpectation do
  it 'flags violations for `expect(current_path)`' do
    expect_offense(<<~RUBY)
      expect(current_path).to eq "/callback"
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_current_path "/callback"
    RUBY
  end

  it 'flags violations for `expect(page.current_path)`' do
    expect_offense(<<-RUBY)
      expect(page.current_path).to eq("/callback")
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY
  end

  it 'registers an offense when a variable is used' do
    expect_offense(<<~RUBY)
      expect(current_path).to eq expected_path
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_current_path expected_path, ignore_query: true
    RUBY
  end

  it 'preserves parentheses' do
    expect_offense(<<~RUBY)
      expect(current_path).to eq(expected_path)
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_current_path(expected_path, ignore_query: true)
    RUBY
  end

  it 'registers an offense with arguments' do
    expect_offense(<<~RUBY)
      expect(current_path).to eq(expected_path(f: :b))
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_current_path(expected_path(f: :b), ignore_query: true)
    RUBY
  end

  it 'registers an offense with method calls' do
    expect_offense(<<~RUBY)
      expect(page.current_path).to eq(foo(bar).path)
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_current_path(foo(bar).path, ignore_query: true)
    RUBY
  end

  it 'registers an offense with negation' do
    expect_offense(<<~RUBY)
      expect(current_path).not_to eq expected_path
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_no_current_path expected_path, ignore_query: true
    RUBY
  end

  it 'registers an offense with to_not negation alias' do
    expect_offense(<<~RUBY)
      expect(current_path).to_not eq expected_path
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_no_current_path expected_path, ignore_query: true
    RUBY
  end

  it 'registers an offense with `match`' do
    expect_offense(<<~RUBY)
      expect(page.current_path).to match(/regexp/i)
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to have_current_path(/regexp/i)
    RUBY
  end

  it 'registers an offense with `match` with a string argument' do
    expect_offense(<<~RUBY)
      expect(page.current_path).to match("string/")
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_correction(<<~'RUBY')
      expect(page).to have_current_path(/string\//)
    RUBY
  end

  it "doesn't flag a violation for other expectations" do
    expect_no_offenses(<<-RUBY)
      expect(current_user).to eq(user)
    RUBY
  end

  it "doesn't flag a violation for other references to `current_path`" do
    expect_no_offenses(<<-RUBY)
      current_path = WalkingRoute.last.path
    RUBY
  end

  it 'ignores `match` with a variable, but does not autocorrect' do
    expect_offense(<<-RUBY)
      expect(page.current_path).to match(variable)
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY

    expect_no_corrections
  end
end
