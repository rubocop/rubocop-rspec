# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterExampleGroup do
  it 'checks for empty line after describe' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        describe '#bar' do
        end
        ^^^ Add an empty line after `describe`.
        describe '#baz' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        describe '#bar' do
        end

        describe '#baz' do
        end
      end
    RUBY
  end

  it 'highlights single line formulations correctly' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        describe('#bar') { }
        ^^^^^^^^^^^^^^^^^^^^ Add an empty line after `describe`.
        describe '#baz' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        describe('#bar') { }

        describe '#baz' do
        end
      end
    RUBY
  end

  it 'checks for empty line after context' do
    expect_offense(<<-RUBY)
      RSpec.context 'foo' do
        context 'bar' do
        end
        ^^^ Add an empty line after `context`.
        context 'baz' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.context 'foo' do
        context 'bar' do
        end

        context 'baz' do
        end
      end
    RUBY
  end

  it 'checks for empty line after shared groups' do
    expect_offense(<<-RUBY)
      RSpec.context 'foo' do
        shared_examples 'bar' do
        end
        ^^^ Add an empty line after `shared_examples`.
        shared_context 'baz' do
        end
        ^^^ Add an empty line after `shared_context`.
        it 'does something' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.context 'foo' do
        shared_examples 'bar' do
        end

        shared_context 'baz' do
        end

        it 'does something' do
        end
      end
    RUBY
  end

  it 'approves empty line after describe' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
        describe '#bar' do
        end

        describe '#baz' do
        end
      end
    RUBY
  end

  it 'approves empty line after context' do
    expect_no_offenses(<<-RUBY)
      RSpec.context 'foo' do
        context 'bar' do
        end

        context 'baz' do
        end
      end
    RUBY
  end

  it 'handles describes in an if block' do
    expect_offense(<<-RUBY)
      if RUBY_VERSION < 2.3
        describe 'skips checks under old ruby' do
        end
      else
        describe 'first check' do
        end
        ^^^ Add an empty line after `describe`.
        describe 'second check' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      if RUBY_VERSION < 2.3
        describe 'skips checks under old ruby' do
        end
      else
        describe 'first check' do
        end

        describe 'second check' do
        end
      end
    RUBY
  end

  it 'does not register an offense for a comment followed by an empty line' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end
        # comment

        describe 'baz' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a comment' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end
        ^^^ Add an empty line after `describe`.
        # comment
        describe 'baz' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end

        # comment
        describe 'baz' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a multiline comment' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end
        ^^^ Add an empty line after `describe`.
        # multiline comment
        # multiline comment
        describe 'baz' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end

        # multiline comment
        # multiline comment
        describe 'baz' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `describe`.
        describe 'baz' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo

        describe 'baz' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a `rubocop:disable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end
        ^^^ Add an empty line after `describe`.
        # rubocop:disable RSpec/Foo
        describe 'baz' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        describe 'bar' do
        end

        # rubocop:disable RSpec/Foo
        describe 'baz' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive ' \
     'when it is followed by a `rubocop:disable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `describe`.
        # rubocop:disable RSpec/Foo
        describe 'baz' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo

        # rubocop:disable RSpec/Foo
        describe 'baz' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end
end
