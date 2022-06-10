# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::SpecificMatcher do
  it 'does not register an offense for abstract matcher when ' \
    'first argument is not a replaceable element' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_selector('article')
      expect(page).to have_no_selector('body')
      expect(page).to have_css('tbody')
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
    'first argument is not an element' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_no_css('.a')
      expect(page).to have_selector('#button')
      expect(page).to have_no_selector('[table]')
    RUBY
  end

  it 'registers an offense when using `have_selector`' do
    expect_offense(<<-RUBY)
    expect(page).to have_selector('button')
                    ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_selector`.
    expect(page).to have_selector('a')
                    ^^^^^^^^^^^^^^^^^^ Prefer `have_link` over `have_selector`.
    expect(page).to have_selector('table')
                    ^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_table` over `have_selector`.
    expect(page).to have_selector('select')
                    ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_select` over `have_selector`.
    RUBY
  end

  it 'registers an offense when using `have_no_selector`' do
    expect_offense(<<-RUBY)
    expect(page).to have_no_selector('button')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_no_button` over `have_no_selector`.
    RUBY
  end

  it 'registers an offense when using `have_css`' do
    expect_offense(<<-RUBY)
    expect(page).to have_css('button')
                    ^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'registers an offense when using `have_no_css`' do
    expect_offense(<<-RUBY)
    expect(page).to have_no_css('button')
                    ^^^^^^^^^^^^^^^^^^^^^ Prefer `have_no_button` over `have_no_css`.
    RUBY
  end

  it 'registers an offense when using abstract matcher and other args' do
    expect_offense(<<-RUBY)
    expect(page).to have_css('button', exact_text: 'foo')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'registers an offense when using abstract matcher with state' do
    expect_offense(<<-RUBY)
    expect(page).to have_css('button[disabled]', exact_text: 'foo')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    expect(page).to have_css('button:not([disabled])', exact_text: 'bar')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
    'first argument is element with nonreplaceable attributes' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_css('button[foo=bar]')
      expect(page).to have_css('button[foo-bar=baz]', exact_text: 'foo')
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
    'first argument is dstr' do
    expect_no_offenses(<<-'RUBY')
      expect(page).to have_css(%{a[href="#{foo}"]}, text: "bar")
    RUBY
  end
end
