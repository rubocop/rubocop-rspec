# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterHook do
  it 'registers an offense for empty line after `before` hook' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        before { do_something }
        ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
        it { does_something }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        before { do_something }

        it { does_something }
      end
    RUBY
  end

  it 'registers an offense for empty line after `after` hook' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        after { do_something }
        ^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `after`.
        it { does_something }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        after { do_something }

        it { does_something }
      end
    RUBY
  end

  it 'registers an offense for empty line after `around` hook' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        around { |test| test.run }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `around`.
        it { does_something }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        around { |test| test.run }

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for empty line after `before` hook' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        before { do_something }

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for empty line after `after` hook' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        after { do_something }

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for empty line after `around` hook' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        around { |test| test.run }

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for multiline `before` block' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        before do
          do_something
        end

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for multiline `after` block' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        after do
          do_something
        end

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for multiline `around` block' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        around do |test|
          test.run
        end

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for `before` being the latest node' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        before { do_something }
      end
    RUBY
  end

  it 'does not register an offense for a comment followed by an empty line' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        before { do_something }
        # comment

        it { does_something }
      end
    RUBY
  end

  it 'flags a missing empty line before a comment' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        before { do_something }
        ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
        # comment
        it { does_something }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        before { do_something }

        # comment
        it { does_something }
      end
    RUBY
  end

  it 'flags a missing empty line before a multiline comment' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        before { do_something }
        ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
        # multiline comment
        # multiline comment
        it { does_something }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        before { do_something }

        # multiline comment
        # multiline comment
        it { does_something }
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        before { do_something }
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
        it { does_something }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        before { do_something }
        # rubocop:enable RSpec/Foo

        it { does_something }
      end
    RUBY
  end

  it 'flags a missing empty line before a `rubocop:disable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        before { do_something }
        ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
        # rubocop:disable RSpec/Foo
        it { does_something }
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        before { do_something }

        # rubocop:disable RSpec/Foo
        it { does_something }
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive '\
      'when it is followed by a `rubocop:disable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        before { do_something }
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
        # rubocop:disable RSpec/Foo
        it { does_something }
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        before { do_something }
        # rubocop:enable RSpec/Foo

        # rubocop:disable RSpec/Foo
        it { does_something }
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end
end
