# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::VisibilityMatcher do
  it 'registers an offense when using `visible: true`' do
    expect_offense(<<-RUBY)
      expect(page).to have_selector('.my_element', visible: true)
                                                   ^^^^^^^^^^^^^ Use `:visible` instead of `true`.
    RUBY
  end

  it 'registers an offense when using `visible: false`' do
    expect_offense(<<-RUBY)
      expect(page).to have_selector('.my_element', visible: false)
                                                   ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
    RUBY
  end

  it 'recognizes multiple matchers' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('.profile', visible: false)
                                           ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_xpath('.//profile', visible: false)
                                               ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_link('news', visible: false)
                                        ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_button('login', visible: false)
                                           ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_field('name', visible: false)
                                         ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_select('sauce', visible: false)
                                           ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_table('arrivals', visible: false)
                                             ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_checked_field('cat', visible: false)
                                                ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_unchecked_field('cat', visible: false)
                                                  ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
    RUBY
  end

  it 'recognizes multiple negative matchers' do
    expect_offense(<<-RUBY)
      expect(page).to have_no_css('.profile', visible: false)
                                              ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_xpath('.//profile', visible: false)
                                                  ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_link('news', visible: false)
                                           ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_button('login', visible: false)
                                              ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_field('name', visible: false)
                                            ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_select('sauce', visible: false)
                                              ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_table('arrivals', visible: false)
                                                ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_checked_field('cat', visible: false)
                                                   ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
      expect(page).to have_no_unchecked_field('cat', visible: false)
                                                     ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
    RUBY
  end

  it 'registers an offense when using a selector`' do
    expect_offense(<<-RUBY)
      expect(page).to have_selector(:css, '.my_element', visible: false)
                                                         ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
    RUBY
  end

  it 'registers an offense when using a using multiple options`' do
    expect_offense(<<-RUBY)
      expect(page).to have_selector('.my_element', count: 1, visible: false, normalize_ws: true)
                                                             ^^^^^^^^^^^^^^ Use `:all` or `:hidden` instead of `false`.
    RUBY
  end

  it 'does not register an offense when no options are given`' do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_selector('.my_element')
    RUBY
  end

  it 'does not register an offense when using `visible: :all`' do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_selector('.my_element', visible: :all)
    RUBY
  end

  it 'does not register an offense when using `visible: :visible`' do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_selector('.my_element', visible: :visible)
    RUBY
  end

  it 'does not register an offense when using `visible: :hidden`' do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_selector('.my_element', visible: :hidden)
    RUBY
  end

  it 'does not register an offense when using other options' do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_selector('.my_element', normalize_ws: true)
    RUBY
  end

  it 'does not register an offense when using multiple options' do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_selector('.my_element', count: 1, normalize_ws: true)
    RUBY
  end
end
