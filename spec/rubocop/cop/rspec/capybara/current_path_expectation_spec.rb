# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::CurrentPathExpectation do
  subject(:cop) { described_class.new }

  it 'flags violations for `expect(current_path)`' do
    expect_offense(<<-RUBY)
      expect(current_path).to eq("/callback")
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
    RUBY
  end

  it 'flags violations for `expect(page.current_path)`' do
    expect_offense(<<-RUBY)
      expect(page.current_path).to eq("/callback")
      ^^^^^^ Do not set an RSpec expectation on `current_path` in Capybara feature specs - instead, use the `have_current_path` matcher on `page`
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

  include_examples 'autocorrect',
                   'expect(current_path).to eq expected_path',
                   'expect(page).to have_current_path expected_path'

  include_examples 'autocorrect',
                   'expect(page.current_path).to eq(foo(bar).path)',
                   'expect(page).to have_current_path(foo(bar).path)'

  include_examples 'autocorrect',
                   'expect(current_path).not_to eq expected_path',
                   'expect(page).to have_no_current_path expected_path'

  include_examples 'autocorrect',
                   'expect(current_path).to_not eq expected_path',
                   'expect(page).to have_no_current_path expected_path'

  include_examples 'autocorrect',
                   'expect(page.current_path).to match(/regexp/i)',
                   'expect(page).to have_current_path(/regexp/i)'

  include_examples 'autocorrect',
                   'expect(page.current_path).to match("string/")',
                   'expect(page).to have_current_path(/string\//)'

  # Unsupported, no change.
  include_examples 'autocorrect',
                   'expect(page.current_path).to match(variable)',
                   'expect(page.current_path).to match(variable)'

  # Unsupported, no change.
  include_examples 'autocorrect',
                   'expect(page.current_path)',
                   'expect(page.current_path)'
end
