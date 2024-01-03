# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterSubject do
  it 'registers an offense for empty line after subject' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        let(:params) { foo }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'registers an offense for empty line after subject!' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject! { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject!`.
        let(:params) { foo }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        subject! { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for empty line after subject' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for empty line after subject!' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        subject! { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for multiline subject block' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        subject do
          described_class.new
        end

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for subject being the latest node' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        subject { described_user }
      end
    RUBY
  end

  it 'does not register an offense for a comment followed by an empty line' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }
        # comment

        describe 'bar' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a comment' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        # comment
        describe 'bar' do
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }

        # comment
        describe 'bar' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a multiline comment' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        # multiline comment
        # multiline comment
        describe 'bar' do
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }

        # multiline comment
        # multiline comment
        describe 'bar' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        subject { described_user }
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        describe 'bar' do
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        subject { described_user }
        # rubocop:enable RSpec/Foo

        describe 'bar' do
        end
      end
    RUBY
  end

  it 'flags a missing empty line before a `rubocop:disable` directive' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe Foo do
        subject { described_user }

        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive ' \
     'when it is followed by a `rubocop:disable` directive' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        subject { described_user }
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        subject { described_user }
        # rubocop:enable RSpec/Foo

        # rubocop:disable RSpec/Foo
        describe 'bar' do
        end
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end
end
