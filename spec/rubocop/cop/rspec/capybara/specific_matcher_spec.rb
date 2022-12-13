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
      expect(page).to have_selector('table')
                      ^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_table` over `have_selector`.
      expect(page).to have_selector('select')
                      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_select` over `have_selector`.
      expect(page).to have_selector('input')
                      ^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_field` over `have_selector`.
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

  it 'registers an offense when using abstract matcher with class selector' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('button.cls')
                      ^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
      expect(page).to have_css('button.cls', text: 'foo')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'registers an offense when using abstract matcher with id selector' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('button#id')
                      ^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
      expect(page).to have_css('button#id', text: 'foo')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  %i[id class style disabled name value title type].each do |attr|
    it 'registers an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_button`' do
      expect_offense(<<-RUBY, attr: attr)
        expect(page).to have_css("button[#{attr}=foo]")
                        ^^^^^^^^^^^^^^^^^^{attr}^^^^^^^ Prefer `have_button` over `have_css`.
      RUBY
    end
  end

  %i[id class style alt title download].each do |attr|
    it 'does not register an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_link` without `href`' do
      expect_no_offenses(<<-RUBY, attr: attr)
        expect(page).to have_css("a")
        expect(page).to have_css("a[#{attr}=foo]")
        expect(page).to have_css("a[#{attr}]")
      RUBY
    end

    it 'registers an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_link` with attribute `href`' do
      expect_offense(<<-RUBY, attr: attr)
        expect(page).to have_css("a[#{attr}=foo][href='http://example.com']")
                        ^^^^^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_link` over `have_css`.
      RUBY
    end

    it 'registers an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_link` with option `href`' do
      expect_offense(<<-RUBY, attr: attr)
        expect(page).to have_css("a[#{attr}=foo]", href: 'http://example.com')
                        ^^^^^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_link` over `have_css`.
        expect(page).to have_css("a[#{attr}=foo]", text: 'foo', href: 'http://example.com')
                        ^^^^^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_link` over `have_css`.
      RUBY
    end
  end

  it 'registers an offense for abstract matcher when ' \
     'first argument is element with replaceable attributes href ' \
     'for `have_link`' do
    expect_offense(<<-RUBY)
      expect(page).to have_css("a[href='http://example.com']")
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_link` over `have_css`.
    RUBY
  end

  %i[id class style cols rows].each do |attr|
    it 'registers an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_table`' do
      expect_offense(<<-RUBY, attr: attr)
        expect(page).to have_css("table[#{attr}=foo]")
                        ^^^^^^^^^^^^^^^^^{attr}^^^^^^^ Prefer `have_table` over `have_css`.
      RUBY
    end
  end

  %i[id class style disabled name placeholder selected multiple].each do |attr|
    it 'registers an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_select`' do
      expect_offense(<<-RUBY, attr: attr)
        expect(page).to have_css("select[#{attr}=foo]")
                        ^^^^^^^^^^^^^^^^^^{attr}^^^^^^^ Prefer `have_select` over `have_css`.
      RUBY
    end
  end

  %i[id class style checked disabled name placeholder].each do |attr|
    it 'registers an offense for abstract matcher when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `have_field`' do
      expect_offense(<<-RUBY, attr: attr)
        expect(page).to have_css("input[#{attr}=foo]")
                        ^^^^^^^^^^^^^^^^^^{attr}^^^^^^ Prefer `have_field` over `have_css`.
      RUBY
    end
  end

  it 'registers an offense when using abstract matcher with ' \
     'first argument is element with multiple replaceable attributes' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('button[disabled=true][name="foo"]', exact_text: 'foo')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'registers an offense when using abstract matcher with state' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('button[disabled=true]', exact_text: 'foo')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'registers an offense when using abstract matcher with ' \
     'first argument is element with replaceable pseudo-classes' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('button:not([disabled=true])', exact_text: 'bar')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
    RUBY
  end

  it 'registers an offense when using abstract matcher with ' \
     'first argument is element with multiple replaceable pseudo-classes' do
    expect_offense(<<-RUBY)
      expect(page).to have_css('button:not([disabled=true]):enabled')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
      expect(page).to have_css('button:not([disabled=false]):disabled')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
      expect(page).to have_css('button:not([disabled=true]):not([disabled=true])')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_button` over `have_css`.
      expect(page).to have_css('input:not([checked=false]):checked')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_field` over `have_css`.
      expect(page).to have_css('input:not([checked=false]):unchecked')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_field` over `have_css`.
      expect(page).to have_css('input:not([checked=true]):not([checked=true])')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `have_field` over `have_css`.
    RUBY
  end

  it 'does not register an offense when using abstract matcher with ' \
     'first argument is element with replaceable pseudo-classes' \
     'and not boolean attributes' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_css('button:not([name="foo"][disabled])')
    RUBY
  end

  it 'does not register an offense when using abstract matcher with ' \
     'first argument is element with multiple nonreplaceable pseudo-classes' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_css('button:first-of-type:not([disabled])')
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
     'first argument is element with nonreplaceable attributes' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_css('button[disabled]')
      expect(page).to have_css('button[data-disabled]')
      expect(page).to have_css('button[foo=bar]')
      expect(page).to have_css('button[foo-bar=baz]', exact_text: 'foo')
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
     'first argument is element with multiple nonreplaceable attributes' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_css('button[disabled=true][foo]')
      expect(page).to have_css('button[foo][disabled=true]')
      expect(page).to have_css('button[foo][disabled=true][bar]')
      expect(page).to have_css('button[disabled=true][foo=bar]')
      expect(page).to have_css('button[disabled=foo][bar]', exact_text: 'foo')
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
     'first argument is element with sub matcher' do
    expect_no_offenses(<<-RUBY)
      expect(page).to have_css('button body')
      expect(page).to have_css('a,h1')
      expect(page).to have_css('table>tr')
      expect(page).to have_css('select+option')
    RUBY
  end

  it 'does not register an offense for abstract matcher when ' \
     'first argument is dstr' do
    expect_no_offenses(<<-'RUBY')
      expect(page).to have_css(%{a[href="#{foo}"]}, text: "bar")
    RUBY
  end
end
