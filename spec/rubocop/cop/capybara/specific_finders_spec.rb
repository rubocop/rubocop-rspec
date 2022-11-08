# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Capybara::SpecificFinders, :config do
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
      find('[visible][id=some-id]')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
      find('[id=some-id][class=some-cls][focused]')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `find_by` over `find`.
    RUBY

    expect_correction(<<~RUBY)
      find_by_id('some-id')
      find_by_id('some-id', visible: true)
      find_by_id('some-id', class: 'some-cls', focused: true)
    RUBY
  end

  it 'does not register an offense when using `find ' \
     'with argument is attribute not specified id' do
    expect_no_offenses(<<~RUBY)
      find('[visible]')
      find('[class=some-cls][visible]')
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
end
