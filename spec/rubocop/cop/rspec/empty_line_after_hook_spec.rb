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
end
