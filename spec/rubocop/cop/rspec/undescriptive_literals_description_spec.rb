# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::UndescriptiveLiteralsDescription, :config do
  it 'registers an offense when using `describe` with only execute string' do
    expect_offense(<<~RUBY)
      describe `time` do
               ^^^^^^ Description should be descriptive.
      end
    RUBY
  end

  it 'registers an offense when using `context` with only execute string' do
    expect_offense(<<~RUBY)
      context `time` do
              ^^^^^^ Description should be descriptive.
      end
    RUBY
  end

  it 'registers an offense when using `it` with only execute string' do
    expect_offense(<<~RUBY)
      it `time` do
         ^^^^^^ Description should be descriptive.
      end
    RUBY
  end

  it 'registers an offense when using `describe` with only regex' do
    expect_offense(<<~RUBY)
      describe /time/ do
               ^^^^^^ Description should be descriptive.
      end
    RUBY
  end

  it 'registers an offense when using `describe` with only Integer' do
    expect_offense(<<~RUBY)
      describe 10000 do
               ^^^^^ Description should be descriptive.
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with method call' do
    expect_no_offenses(<<~RUBY)
      describe foo.to_s do
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with local variable' do
    expect_no_offenses(<<~RUBY)
      types.each do |type|
        describe type do
        end
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with ' \
     'instance variable' do
    expect_no_offenses(<<~RUBY)
      describe @foo do
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with ' \
     'grobal variable' do
    expect_no_offenses(<<~RUBY)
      describe $foo do
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with a string' do
    expect_no_offenses(<<~RUBY)
      describe '#foo' do
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with a class' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
      end
    RUBY
  end

  it 'does not register an offense when using `context` with a string' do
    expect_no_offenses(<<~RUBY)
      context 'when foo is bar' do
      end
    RUBY
  end

  it 'does not register an offense when using `it` with a string' do
    expect_no_offenses(<<~RUBY)
      it 'does something' do
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with an ' \
     'interpolation string' do
    expect_no_offenses(<<~RUBY)
      describe "foo \#{bar}" do
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with a ' \
     'heredoc string' do
    expect_no_offenses(<<~RUBY)
      describe <<~DESC do
        foo
      DESC
      end
    RUBY
  end

  it 'does not register an offense when using `describe` with a ' \
     'string concatenation' do
    expect_no_offenses(<<~RUBY)
      describe 'foo' + `time` do
        context 'when ' + 1.to_s do
          it 'returns ' + /something/.to_s do
          end
        end
      end
    RUBY
  end
end
