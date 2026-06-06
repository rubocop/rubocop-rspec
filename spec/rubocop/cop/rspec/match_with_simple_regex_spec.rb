# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MatchWithSimpleRegex, :config do
  it 'registers an offense when using match with simple string regex' do
    expect_offense(<<~RUBY)
      expect('foobar').to match(/foo/)
                          ^^^^^^^^^^^^ Prefer using `include('foo')` when the regex is a simple string literal.
    RUBY

    expect_correction(<<~RUBY)
      expect('foobar').to include('foo')
    RUBY
  end

  it 'registers an offense when using match with escaped URL regex' do
    expect_offense(<<~'RUBY')
      expect(response.body).to match(/http:\/\/example\.com/)
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `include('http://example.com')` when the regex is a simple string literal.
    RUBY

    expect_correction(<<~RUBY)
      expect(response.body).to include('http://example.com')
    RUBY
  end

  it 'registers an offense when using match with string containing ' \
     'single quotes' do
    expect_offense(<<~'RUBY')
      expect(response).to match(/it's "working"/)
                          ^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `include("it's \"working\"")` when the regex is a simple string literal.
    RUBY

    expect_correction(<<~'RUBY')
      expect(response).to include("it's \"working\"")
    RUBY
  end

  it 'registers an offense when using match with string containing newline' do
    expect_offense(<<~RUBY)
      expect(response).to match(/foo
                          ^^^^^^^^^^ Prefer using [...]
        bar/)
    RUBY

    expect_correction(<<~RUBY)
      expect(response).to include('foo
        bar')
    RUBY
  end

  it 'does not register an offense when using match with anchor at start' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/^foo/)
    RUBY
  end

  it 'does not register an offense when using match with anchor at end' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/foo$/)
    RUBY
  end

  it 'does not register an offense when using match with character class' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/foo[ob]/)
    RUBY
  end

  it 'does not register an offense when using match with quantifier' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/foo+/)
    RUBY
  end

  it 'does not register an offense when using match with alternation' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/foo|bar/)
    RUBY
  end

  it 'does not register an offense when using match with metacharacter' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/foo.bar/)
    RUBY
  end

  it 'does not register an offense when using match with interpolation' do
    expect_no_offenses(<<~'RUBY')
      expect('foobar').to match(/foo-#{bar}/)
    RUBY
  end

  it 'does not register an offense when using match with regex options' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(/foo/x)
      expect('foobar').to match(/foo/i)
      expect('foobar').to match(/foo/m)
      expect('foobar').to match(/foo/n)
      expect('foobar').to match(/foo/u)
      expect('foobar').to match(/foo/o)
    RUBY
  end

  it 'does not register an offense when using match with string ' \
     'instead of regex' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match('foo')
    RUBY
  end

  it 'does not register an offense when using match with variable' do
    expect_no_offenses(<<~RUBY)
      expect('foobar').to match(pattern)
    RUBY
  end
end
