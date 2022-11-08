# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::SpecificActions, :config do
  it 'does not register an offense for find and click action when ' \
     'first argument is link' do
    expect_no_offenses(<<~RUBY)
      find('a').click
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'first argument is link with href' do
    expect_offense(<<~RUBY)
      find('a', href: 'http://example.com').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      find("a[href]").click
      ^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      find("a[href='http://example.com']").click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'first argument is button' do
    expect_offense(<<~RUBY)
      find('button').click
      ^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'first argument is button with class' do
    expect_offense(<<~RUBY)
      find('button.cls').click
      ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'consecutive chain methods' do
    expect_offense(<<~RUBY)
      find("a").find('button').click
                ^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click action with ' \
     'other argument' do
    expect_offense(<<~RUBY)
      find('button', exact_text: 'foo').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click aciton when ' \
     'first argument is multiple selector ` `' do
    expect_offense(<<~RUBY)
      find('div button').click
      ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'does not register an offense for find and click aciton when ' \
     'first argument is multiple selector `,`' do
    expect_no_offenses(<<-RUBY)
      find('button,a').click
      find('a, button').click
    RUBY
  end

  it 'does not register an offense for find and click aciton when ' \
     'first argument is multiple selector `>`' do
    expect_no_offenses(<<-RUBY)
      find('button>a').click
      find('a > button').click
    RUBY
  end

  it 'does not register an offense for find and click aciton when ' \
     'first argument is multiple selector `+`' do
    expect_no_offenses(<<-RUBY)
      find('button+a').click
      find('a + button').click
    RUBY
  end

  it 'does not register an offense for find and click aciton when ' \
     'first argument is multiple selector `~`' do
    expect_no_offenses(<<-RUBY)
      find('button~a').click
      find('a ~ button').click
    RUBY
  end

  %i[above below left_of right_of near count minimum maximum between
     text id class style visible obscured exact exact_text normalize_ws
     match wait filter_set focused disabled name value
     title type].each do |attr|
    it 'registers an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_button`' do
      expect_offense(<<-RUBY, attr: attr)
        find("button[#{attr}=foo]").click
        ^^^^^^^^^^^^^^{attr}^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
        find("button[#{attr}]").click
        ^^^^^^^^^^^^^^{attr}^^^^^^^^^ Prefer `click_button` over `find('button').click`.
      RUBY
    end
  end

  %i[above below left_of right_of near count minimum maximum between text id
     class style visible obscured exact exact_text normalize_ws match wait
     filter_set focused alt title download].each do |attr|
    it 'does not register an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_link` without `href`' do
      expect_no_offenses(<<-RUBY, attr: attr)
        find("a[#{attr}=foo]").click
        find("a[#{attr}]").click
      RUBY
    end

    it 'registers an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_link` with attribute `href`' do
      expect_offense(<<-RUBY, attr: attr)
        find("a[#{attr}=foo][href]").click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
        find("a[#{attr}][href='http://example.com']").click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      RUBY
    end

    it 'registers an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_link` with option `href`' do
      expect_offense(<<-RUBY, attr: attr)
        find("a[#{attr}=foo]", href: 'http://example.com').click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
        find("a[#{attr}]", text: 'foo', href: 'http://example.com').click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      RUBY
    end
  end

  it 'registers an offense when using abstract action with ' \
     'first argument is element with multiple replaceable attributes' do
    expect_offense(<<-RUBY)
      find('button[disabled][name="foo"]', exact_text: 'foo').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using abstract action with state' do
    expect_offense(<<-RUBY)
      find('button[disabled]', exact_text: 'foo').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using abstract action with ' \
     'first argument is element with replaceable pseudo-classes' do
    expect_offense(<<-RUBY)
      find('button:not([disabled])', exact_text: 'bar').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
      find('button:not([disabled][visible])').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using abstract action with ' \
     'first argument is element with multiple replaceable pseudo-classes' do
    expect_offense(<<-RUBY)
      find('button:not([disabled]):enabled').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
      find('button:not([disabled=false]):disabled').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
      find('button:not([disabled]):not([disabled])').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'does not register an offense when using abstract action with ' \
     'first argument is element with replaceable pseudo-classes' \
     'and not boolean attributes' do
    expect_no_offenses(<<-RUBY)
      find('button:not([name="foo"][disabled])').click
    RUBY
  end

  it 'does not register an offense when using abstract action with ' \
     'first argument is element with multiple nonreplaceable pseudo-classes' do
    expect_no_offenses(<<-RUBY)
      find('button:first-of-type:not([disabled])').click
    RUBY
  end

  it 'does not register an offense for abstract action when ' \
     'first argument is element with nonreplaceable attributes' do
    expect_no_offenses(<<-RUBY)
      find('button[data-disabled]').click
      find('button[foo=bar]').click
      find('button[foo-bar=baz]', exact_text: 'foo').click
    RUBY
  end

  it 'does not register an offense for abstract action when ' \
     'first argument is element with multiple nonreplaceable attributes' do
    expect_no_offenses(<<-RUBY)
      find('button[disabled][foo]').click
      find('button[foo][disabled]').click
      find('button[foo][disabled][bar]').click
      find('button[disabled][foo=bar]').click
      find('button[disabled=foo][bar]', exact_text: 'foo').click
    RUBY
  end

  it 'does not register an offense for find and click aciton when ' \
     'first argument is not a replaceable element' do
    expect_no_offenses(<<-RUBY)
      find('article').click
      find('body').click
    RUBY
  end

  it 'does not register an offense for find and click aciton when ' \
     'first argument is not an element' do
    expect_no_offenses(<<-RUBY)
      find('.a').click
      find('#button').click
      find('[a]').click
    RUBY
  end
end
