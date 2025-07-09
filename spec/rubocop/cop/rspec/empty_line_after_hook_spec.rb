# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterHook do
  shared_examples_for 'always require empty line after hook groups' do
    it 'registers an offense for multiline blocks without empty line before' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          before do
            do_something
          end
          ^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something_else }

          before do
            do_something
          end

          it { does_something }
        end
      RUBY
    end

    it 'registers an offense for empty line after `before` hook' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          it { does_something }
        end
      RUBY
    end

    it 'registers an offense for empty line after `after` hook' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          after { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `after`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          after { do_something }

          it { does_something }
        end
      RUBY
    end

    it 'registers an offense for empty line after `around` hook' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          around { |test| test.run }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `around`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { |test| test.run }

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for empty line after `before` hook' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for empty line after `after` hook' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          after { do_something }

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for empty line after `around` hook' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          around { |test| test.run }

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for multiline `before` block' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          before do
            do_something
          end

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for multiline `after` block' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          after do
            do_something
          end

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for multiline `around` block' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          around do |test|
            test.run
          end

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for `before` being the latest node' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          before { do_something }
        end
      RUBY
    end

    it 'does not register an offense for a comment followed by an empty line' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          # comment

          it { does_something }
        end
      RUBY
    end

    it 'flags a missing empty line before a comment' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          # comment
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          # comment
          it { does_something }
        end
      RUBY
    end

    it 'flags a missing empty line before a multiline comment' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          # multiline comment
          # multiline comment
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          # multiline comment
          # multiline comment
          it { does_something }
        end
      RUBY
    end

    it 'flags a missing empty line after a `rubocop:enable` directive' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          # rubocop:disable RSpec/Foo
          before { do_something }
          # rubocop:enable RSpec/Foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          # rubocop:disable RSpec/Foo
          before { do_something }
          # rubocop:enable RSpec/Foo

          it { does_something }
        end
      RUBY
    end

    it 'flags a missing empty line before a `rubocop:disable` directive' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          # rubocop:disable RSpec/Foo
          it { does_something }
          # rubocop:enable RSpec/Foo
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          # rubocop:disable RSpec/Foo
          it { does_something }
          # rubocop:enable RSpec/Foo
        end
      RUBY
    end

    it 'flags a missing empty line after a `rubocop:enable` directive ' \
       'when it is followed by a `rubocop:disable` directive' do
      expect_offense(<<~RUBY)
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

      expect_correction(<<~RUBY)
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

  shared_examples_for 'never allows consecutive multiline blocks' do
    it 'registers an offense for multiline blocks without empty line after' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before do
            do_something
          end
          ^^^ Add an empty line after `before`.
          before { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before do
            do_something
          end

          before { do_something_else }

          it { does_something }
        end
      RUBY
    end
  end

  context 'when AllowConsecutiveOneLiners option has default value `true`' do
    it_behaves_like 'always require empty line after hook groups'
    it_behaves_like 'never allows consecutive multiline blocks'

    it 'ignores multiple one-liner blocks' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          before { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          before { do_something_else }

          it { does_something }
        end
      RUBY
    end

    it 'ignores multiple one-liner blocks with comments' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          # this is a comment
          before { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          # this is a comment
          before { do_something_else }

          it { does_something }
        end
      RUBY
    end

    it 'does not register an offense for chained one-liner `before` hooks' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          before { do_something_else }

          it { does_something }
        end
      RUBY
    end

    it 'allows chained one-liner with different hooks' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          before { do_something_else }
          after { do_something_else }

          it { does_something }
        end
      RUBY
    end
  end

  context 'when AllowConsecutiveOneLiners option `false`' do
    let(:cop_config) { { 'AllowConsecutiveOneLiners' => false } }

    it_behaves_like 'always require empty line after hook groups'
    it_behaves_like 'never allows consecutive multiline blocks'

    it 'registers an offense for multiple one-liner same hook blocks' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          before { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          before { do_something_else }

          it { does_something }
        end
      RUBY
    end

    it 'registers an offense for multiple one-liner blocks with comments' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          # this is a comment
          before { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          # this is a comment
          before { do_something_else }

          it { does_something }
        end
      RUBY
    end

    it 'registers an offense for multiple one-liner different hook blocks' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          before { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `before`.
          after { do_something_else }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `after`.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          before { do_something }

          after { do_something_else }

          it { does_something }
        end
      RUBY
    end

    context 'when Ruby 2.7', :ruby27 do
      it 'registers an offense for empty line after `around` hook' do
        expect_offense(<<~RUBY)
          RSpec.describe User do
            around { _1.run }
            ^^^^^^^^^^^^^^^^^ Add an empty line after `around`.
            it { does_something }
          end
        RUBY

        expect_correction(<<~RUBY)
          RSpec.describe User do
            around { _1.run }

            it { does_something }
          end
        RUBY
      end

      it 'does not register an offense for multiline `around` block' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe User do
            around do
              _1.run
            end

            it { does_something }
          end
        RUBY
      end
    end
  end
end
