# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ContextMethod do
  it 'ignores describe blocks' do
    expect_no_offenses(<<~RUBY)
      describe '.foo_bar' do
      end

      describe '#foo_bar' do
      end
    RUBY
  end

  it 'ignores context without `.` or `#` at the beginning' do
    expect_no_offenses(<<~RUBY)
      context "when it's sunny" do
      end
    RUBY
  end

  it 'flags context with `.` at the beginning' do
    expect_offense(<<~RUBY)
      context '.foo_bar' do
              ^^^^^^^^^^ Use `describe` for testing methods.
      end
    RUBY

    expect_correction(<<~RUBY)
      describe '.foo_bar' do
      end
    RUBY
  end

  it 'flags context with `#` at the beginning' do
    expect_offense(<<~RUBY)
      context '#foo_bar' do
              ^^^^^^^^^^ Use `describe` for testing methods.
      end
    RUBY

    expect_correction(<<~RUBY)
      describe '#foo_bar' do
      end
    RUBY
  end

  it 'flags multi-line context with `#` at the beginning' do
    expect_offense(<<~'RUBY')
      context '#foo_bar' \
              ^^^^^^^^^^^^ Use `describe` for testing methods.
              '.baz'do
      end
    RUBY

    expect_correction(<<~'RUBY')
      describe '#foo_bar' \
              '.baz'do
      end
    RUBY
  end

  it 'flags context with `.` at the beginning with block-pass' do
    expect_offense(<<~RUBY)
      context '.foo_bar', &blk
              ^^^^^^^^^^ Use `describe` for testing methods.
    RUBY

    expect_correction(<<~RUBY)
      describe '.foo_bar', &blk
    RUBY
  end

  it 'flags context with `#` at the beginning with block-pass and metadata' do
    expect_offense(<<~RUBY)
      RSpec.context('#foo_bar', :foo, &blk)
                    ^^^^^^^^^^ Use `describe` for testing methods.
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe('#foo_bar', :foo, &blk)
    RUBY
  end

  it 'ignores context without `.` or `#` at the beginning with block-pass' do
    expect_no_offenses(<<~RUBY)
      context 'foo_bar', &blk
    RUBY
  end

  it 'ignores describe with block-pass' do
    expect_no_offenses(<<~RUBY)
      describe '#foo_bar', &blk
    RUBY
  end
end
