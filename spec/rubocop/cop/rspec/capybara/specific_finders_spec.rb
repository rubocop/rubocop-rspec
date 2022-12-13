# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::SpecificFinders, :config do
  it 'registers an offense when using `find`' do
    expect_offense(<<~RUBY)
      find('#some-id')
      ^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id')
    RUBY
  end

  it 'registers an offense when using `find` with no parentheses' do
    expect_offense(<<~RUBY)
      find "#some-id"
      ^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id 'some-id'
    RUBY
  end

  it 'registers an offense when using `find` with id and class' do
    expect_offense(<<~RUBY)
      find('#some-id.some-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id', class: 'some-cls')
    RUBY
  end

  it 'registers an offense when using `find` with id include `\.`' do
    expect_offense(<<~RUBY)
      find('#some-id\\.some-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
      find('#some-id\\>some-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
      find('#some-id\\,some-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
      find('#some-id\\+some-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
      find('#some-id\\~some-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id.some-cls')
      find_by_id('some-id>some-cls')
      find_by_id('some-id,some-cls')
      find_by_id('some-id+some-cls')
      find_by_id('some-id~some-cls')
    RUBY
  end

  it 'registers an offense when using `find` with multiple classes' do
    expect_offense(<<~RUBY)
      find('#some-id.some-cls.other-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id', class: ["some-cls", "other-cls"])
    RUBY
  end

  it 'registers an offense when using `find` with multiple classes ' \
     "and class: 'other-cls'" do
    expect_offense(<<~RUBY)
      find('#some-id.some-cls', class: 'other-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id', class: ["some-cls", "other-cls"])
    RUBY
  end

  it 'registers an offense when using `find` with multiple classes ' \
     "and class: ['other-cls1', 'other-cls2']" do
    expect_offense(<<~RUBY)
      find('#some-id.some-cls', class: ['other-cls1', 'other-cls2'])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id', class: ["some-cls", "other-cls1", "other-cls2"])
    RUBY
  end

  it 'registers an offense when using `find` with multiple classes ' \
     "and exact_text: 'foo', class: 'other-cls'" do
    expect_offense(<<~RUBY)
      find('#some-id.some-cls', exact_text: 'foo', class: 'other-cls')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id', exact_text: 'foo', class: ["some-cls", "other-cls"])
    RUBY
  end

  it 'registers an offense when using `find` and other args' do
    expect_offense(<<~RUBY)
      find('#some-id', exact_text: 'foo')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id', exact_text: 'foo')
    RUBY
  end

  it 'registers an offense when using `find` and other args ' \
     'with no parentheses' do
    expect_offense(<<~RUBY)
      find '#some-id', exact_text: 'foo'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id 'some-id', exact_text: 'foo'
    RUBY
  end

  it 'registers an offense when using `find` with method chain' do
    expect_offense(<<~RUBY)
      find('#some-id').find('#other-id').find('#another-id')
      ^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
                       ^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
                                         ^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id').find_by_id('other-id').find_by_id('another-id')
    RUBY
  end

  it 'registers an offense when using `find ' \
     'with argument is attribute specified id' do
    expect_offense(<<~RUBY)
      find('[id=some-id]')
      ^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id')
    RUBY
  end

  it 'registers an offense when using `find ' \
     'with argument is attribute specified id surrounded by quotation' do
    expect_offense(<<~RUBY)
      find('[id="foo"]')
      ^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
      find('[id="foo[bar]"]')
      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('foo')
      find_by_id('foo[bar]')
    RUBY
  end

  it 'does not register an offense when using `find ' \
     'with argument is attribute not specified id' do
    expect_no_offenses(<<~RUBY)
      find('[id]')
      find('[disabled=true]')
      find('[class=some-cls][disabled]')
    RUBY
  end

  it 'does not register an offense when using `find ' \
     'with argument is attribute specified id and class' do
    expect_no_offenses(<<~RUBY)
      find('[class=some-cls][id=some-id]')
      find('[id=some-id][disabled][class=some-cls]')
    RUBY
  end

  it 'does not register an offense when using `find ' \
     'with argument is element with id' do
    expect_no_offenses(<<~RUBY)
      find('h1#some-id')
    RUBY
  end

  it 'does not register an offense when using `find ' \
     'with argument is element with attribute specified id' do
    expect_no_offenses(<<~RUBY)
      find('h1[id=some-id]')
    RUBY
  end

  it 'does not register an offense when using `find` ' \
     'with argument is not id' do
    expect_no_offenses(<<~RUBY)
      find('a.some-id')
      find('.some-id')
    RUBY
  end

  it 'does not register an offense when using `find_by_id`' do
    expect_no_offenses(<<~RUBY)
      find_by_id('some-id')
    RUBY
  end

  it 'does not register an offense when using `find` ' \
     'with argument is id with multiple matcher' do
    expect_no_offenses(<<~RUBY)
      find('#some-id body')
      find('#some-id>h1')
      find('#some-id,h2')
      find('#some-id+option')
    RUBY
  end

  it 'does not register an offense when using `find` ' \
     'with id and attribute' do
    expect_no_offenses(<<~RUBY)
      find('#foo[hidden]')
      find('#foo[class="some-cls"]')
    RUBY
  end

  it 'does not register an offense when using `find` ' \
     'with id and pseudo class' do
    expect_no_offenses(<<~RUBY)
      find('#foo:enabled')
      find('#foo:not(:disabled)')
      find('#foo:is(:enabled,:checked)')
    RUBY
  end
end
