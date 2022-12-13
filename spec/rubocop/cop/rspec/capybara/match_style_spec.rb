# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::MatchStyle, :config do
  it 'registers an offense when using `assert_style`' do
    expect_offense(<<~RUBY)
      page.find(:css, '#first').assert_style(display: 'block')
                                ^^^^^^^^^^^^ Use `assert_matches_style` instead of `assert_style`.
    RUBY

    expect_correction(<<~RUBY)
      page.find(:css, '#first').assert_matches_style(display: 'block')
    RUBY
  end

  it 'registers an offense when using `has_style?`' do
    expect_offense(<<~RUBY)
      expect(page.find(:css, 'first')
        .has_style?(display: 'block')).to be true
         ^^^^^^^^^^ Use `matches_style?` instead of `has_style?`.
    RUBY

    expect_correction(<<~RUBY)
      expect(page.find(:css, 'first')
        .matches_style?(display: 'block')).to be true
    RUBY
  end

  it 'registers an offense when using `have_style`' do
    expect_offense(<<~RUBY)
      expect(page).to have_style(display: 'block')
                      ^^^^^^^^^^ Use `match_style` instead of `have_style`.
    RUBY

    expect_correction(<<~RUBY)
      expect(page).to match_style(display: 'block')
    RUBY
  end

  it 'does not register an offense when using `assert_matches_style`' do
    expect_no_offenses(<<~RUBY)
      page.find(:css, '#first').assert_matches_style(display: 'block')
    RUBY
  end

  it 'does not register an offense when using `matches_style?`' do
    expect_no_offenses(<<~RUBY)
      expect(page.find(:css, 'first').matches_style?(display: 'block')).to be true
    RUBY
  end

  it 'does not register an offense when using `match_style`' do
    expect_no_offenses(<<~RUBY)
      expect(page).to match_style(display: 'block')
    RUBY
  end
end
