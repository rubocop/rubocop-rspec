# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::PendingWithoutReason do
  context 'when pending by pending/skip statement with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~'RUBY')
        RSpec.describe Foo do
          it 'does something' do
            pending 'reason'
            pending "#{reason}"
            pending `echo #{reason}`
            skip 'reason'
            skip "#{reason}"
            skip `echo #{reason}`
          end
        end
      RUBY
    end
  end

  context 'when pending/skip by metadata on example with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something', pending: 'reason' do
          end
          it 'does something', skip: 'reason' do
          end
        end
      RUBY
    end
  end

  context 'when pending by pending/skip step without reason ' \
          'and not inside example' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :task do
            pending
            skip
            pending { true }
            skip { true }
          end
        end
      RUBY
    end
  end

  context 'when pending/skip with receiver' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            Foo.pending
            Foo.skip
          end
        end
      RUBY
    end
  end

  context 'when pending is argument of methods' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            expect('foo').to eq pending
            foo(bar, pending)
            foo(bar, pending: pending)
            is_expected.to match_array [foo, pending, bar]
          end
        end
      RUBY
    end
  end

  context 'when skip is argument of methods' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            expect('foo').to eq skip
            foo(bar, skip)
            foo(bar, skip: skip)
            is_expected.to match_array [foo, skip, bar]
          end
        end
      RUBY
    end
  end

  context 'when pending/skip is argument of methods' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            list = [skip, pending]
            foo(list)
          end
        end
      RUBY
    end
  end

  context 'when pending by example method with block' do
    it 'registers no offense' do
      # Because `ArgumentError` is raised whenblock is given to example method.
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          pending 'does something' do
          end
        end
      RUBY
    end
  end

  context 'when pending by example method with block ' \
          'inside examples block' do
    it 'registers no offense' do
      # Because `ArgumentError` is raised when block is given to example method.
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            do_something
            pending 'does something' do
              do_something
            end
            do_something
          end
        end
      RUBY
    end
  end

  context 'when pending by metadata on example without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          it 'does something', :pending do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
          end
        end
      RUBY
    end
  end

  context 'when pending by metadata on example group without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'something', :pending do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
        end
      RUBY
    end
  end

  context 'when pending by hash metadata on example group without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'something', pending: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
        end
      RUBY
    end
  end

  context 'when pending by pending step without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          pending
          ^^^^^^^ Give the reason for pending.
        end
        RSpec.describe Foo do
          context 'when something' do
            pending
            ^^^^^^^ Give the reason for pending.
          end
        end
        RSpec.describe Foo do
          it 'does something' do
            pending
            ^^^^^^^ Give the reason for pending.
          end
        end
      RUBY
    end
  end

  context 'when pending by pending step without reason with other step' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          pending
          ^^^^^^^ Give the reason for pending.
          before { buzz! }
          context 'when something' do
            let(:foo) { 'bar' }
            pending
            ^^^^^^^ Give the reason for pending.
            it 'does something' do
              do_something
              pending
              ^^^^^^^ Give the reason for pending.
              do_something
            end
          end
        end
      RUBY
    end
  end

  context 'when pending/skip inside conditional' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            pending if RUBY_VERSION < '3.0'
            if RUBY_VERSION < '3.0'
              skip
            end
          end
        end
      RUBY
    end
  end

  context 'when skipped by example group method' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        xdescribe 'something' do
        ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
        end
      RUBY
    end
  end

  context 'when skipped by example method with block' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          skip 'does something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
        end
      RUBY
    end
  end

  context 'when skipped by example method with block ' \
          'inside examples block' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            do_something
            skip 'does something' do
            ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
              do_something
            end
            do_something
          end
        end
      RUBY
    end
  end

  context 'when skipped by metadata on example without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          it 'does something', skip: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
        end
      RUBY
    end
  end

  context 'when skipped by metadata on example group without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'something', skip: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
        end
      RUBY
    end
  end

  context 'when skipped by skip without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          skip
          ^^^^ Give the reason for skip.
        end
        RSpec.describe Foo do
          context 'when something' do
            skip
            ^^^^ Give the reason for skip.
          end
        end
        RSpec.describe Foo do
          it 'does something' do
            skip
            ^^^^ Give the reason for skip.
          end
        end
      RUBY
    end
  end

  context 'when skipped by skip without reason with other step' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          do_something
          skip
          ^^^^ Give the reason for skip.
          context 'when something' do
            skip
            ^^^^ Give the reason for skip.
            do_something
            it 'does something' do
              do_something
              skip
              ^^^^ Give the reason for skip.
              do_something
            end
          end
        end
      RUBY
    end
  end

  context 'when Ruby 2.7 and using numblock', :ruby27 do
    context 'when pending/skip by metadata on example with reason' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            it 'does something', pending: 'reason' do
              _1.do_something
            end
            it 'does something', skip: 'reason' do
              _1.do_something
            end
          end
        RUBY
      end
    end

    context 'when pending/skip with receiver' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            it 'does something' do
              _1.pending
              _1.skip
            end
          end
        RUBY
      end
    end

    context 'when pending by example method with block' do
      it 'registers no offense' do
        # Because `ArgumentError` is raised
        # when block is given to example method.
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            pending 'does something' do
              _1.do_something
            end
          end
        RUBY
      end
    end

    context 'when pending by example method with block ' \
            'inside examples block' do
      it 'registers no offense' do
        # Because `ArgumentError` is raised
        # when block is given to example method.
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            it 'does something' do
              do_something
              pending 'does something' do
                _1.do_something
              end
              do_something
            end
          end
        RUBY
      end
    end

    context 'when pending by metadata on example without reason' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            it 'does something', :pending do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
              _1.do_something
            end
          end
        RUBY
      end
    end

    context 'when pending by metadata on example group without reason' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'something', :pending do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
            _1.do_something
          end
        RUBY
      end
    end

    context 'when pending by hash metadata on example group without reason' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'something', pending: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
            _1.do_something
          end
        RUBY
      end
    end

    context 'when skipped by example group method' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          xdescribe 'something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
            _1.do_something
          end
        RUBY
      end
    end

    context 'when skipped by example method with block' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            skip 'does something' do
            ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
              _1.do_something
            end
          end
        RUBY
      end
    end

    context 'when skipped by example method with block ' \
            'inside examples block' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            it 'does something' do
              do_something
              skip 'does something' do
              ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
                _1.do_something
              end
              do_something
            end
          end
        RUBY
      end
    end

    context 'when skipped by metadata on example without reason' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            it 'does something', skip: true do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
              _1.do_something
            end
          end
        RUBY
      end
    end

    context 'when skipped by metadata on example group without reason' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'something', skip: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
            _1.do_something
          end
        RUBY
      end
    end

    context 'when pending by pending step without reason with other step' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            pending
            ^^^^^^^ Give the reason for pending.
            _1.do_something
            context 'when something' do
              _1.do_something
              pending
              ^^^^^^^ Give the reason for pending.
              it 'does something' do
                _1.do_something
                pending
                ^^^^^^^ Give the reason for pending.
                _1.do_something
              end
            end
          end
        RUBY
      end
    end

    context 'when skipped by skip step without reason with other step' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            _1.do_something
            skip
            ^^^^ Give the reason for skip.
            context 'when something' do
              skip
              ^^^^ Give the reason for skip.
              _1.do_something
              it 'does something' do
                _1.do_something
                skip
                ^^^^ Give the reason for skip.
                _1.do_something
              end
            end
          end
        RUBY
      end
    end
  end
end
