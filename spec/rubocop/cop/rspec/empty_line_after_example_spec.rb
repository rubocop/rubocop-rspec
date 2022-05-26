# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterExample do
  it 'flags a missing empty line after `it`' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end
        ^^^ Add an empty line after `it`.
        it 'does that' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end

        it 'does that' do
        end
      end
    RUBY
  end

  it 'flags one-line examples' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        it { }
        ^^^^^^ Add an empty line after `it`.
        it 'does that' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        it { }

        it 'does that' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line after `specify`' do
    expect_offense(<<-RUBY)
      RSpec.context 'foo' do
        specify do
        end
        ^^^ Add an empty line after `specify`.
        specify 'something gets done' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.context 'foo' do
        specify do
        end

        specify 'something gets done' do
        end
      end
    RUBY
  end

  it 'ignores when an empty line is present' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end

        it 'does that' do
        end
      end
    RUBY
  end

  it 'ignores consecutive one-liners' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
        it { one }
        it { two }
      end
    RUBY
  end

  it 'flags mixed one-line and multi-line examples' do
    expect_offense(<<-RUBY)
      RSpec.context 'foo' do
        it { }
        it { }
        ^^^^^^ Add an empty line after `it`.
        it 'does this' do
        end
        ^^^ Add an empty line after `it`.
        it { }
        it { }
      end
    RUBY
  end

  it 'does not register an offense for a comment followed by an empty line' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end
        # comment

        it 'does that' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a comment' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end
        ^^^ Add an empty line after `it`.
        # comment
        it 'does that' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end

        # comment
        it 'does that' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a multiline comment' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end
        ^^^ Add an empty line after `it`.
        # multiline comment
        # multiline comment
        it 'does that' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end

        # multiline comment
        # multiline comment
        it 'does that' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        it 'does this' do
        end
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `it`.
        it 'does that' do
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        it 'does this' do
        end
        # rubocop:enable RSpec/Foo

        it 'does that' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a `rubocop:disable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end
        ^^^ Add an empty line after `it`.
        # rubocop:disable RSpec/Foo
        it 'does that' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        it 'does this' do
        end

        # rubocop:disable RSpec/Foo
        it 'does that' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive '\
      'when it is followed by a `rubocop:disable` directive' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        it 'does this' do
        end
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `it`.
        # rubocop:disable RSpec/Foo
        it 'does that' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe Foo do
        # rubocop:disable RSpec/Foo
        it 'does this' do
        end
        # rubocop:enable RSpec/Foo

        # rubocop:disable RSpec/Foo
        it 'does that' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  context 'when AllowConsecutiveOneLiners is false' do
    let(:cop_config) { { 'AllowConsecutiveOneLiners' => false } }

    it 'ignores consecutive one-liners' do
      expect_offense(<<-RUBY)
        RSpec.describe Foo do
          it { one }
          ^^^^^^^^^^ Add an empty line after `it`.
          it { two }
        end
      RUBY
    end
  end
end
