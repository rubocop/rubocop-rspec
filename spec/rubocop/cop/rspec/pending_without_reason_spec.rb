# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::PendingWithoutReason, :ruby27 do
  context 'when pending/skip has a reason inside an example' do
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

  context 'when pending/skip has a reason inside an example group' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          skip 'does something'
          pending 'does something'
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
          it 'does something', pending: 'reason' do
            _1
          end
          it 'does something', skip: 'reason' do
            _1
          end
        end
      RUBY
    end
  end

  context 'when pending/skip by metadata on example group with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        describe 'something', pending: 'reason' do
        end
        describe 'something', skip: 'reason' do
        end
        describe 'something', pending: 'reason' do
          _1
        end
        describe 'something', skip: 'reason' do
          _1
        end
      RUBY
    end
  end

  context 'when pending/skip not inside an example' do
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
          it 'does something' do
            _1.pending
            _1.skip
          end
        end
      RUBY
    end
  end

  context 'when pending/skip is an argument' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            expect('foo').to eq(pending)
            expect('foo').to eq(skip)
            foo(bar, pending, skip)
            foo(bar, pending: pending, skip: skip)
            is_expected.to match_array([foo, pending, skip, bar])
            list = [skip, pending]
            foo(list)
          end
        end
      RUBY
    end
  end

  context 'when pending/skip by example method with block' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          pending 'does something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
          end
          skip 'does something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
          skip 'does something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
            _1
          end
        end
      RUBY
    end
  end

  context 'when pending inside an example with a block' do
    it 'registers no offense' do
      # `ArgumentError` is raised when block is given to `pending` inside
      # an example.
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            pending 'does something' do
              do_something
            end
            pending 'does something' do
              _1.do_something
            end
          end
        end
      RUBY
    end
  end

  context 'when skip inside an example with a block' do
    it 'registers no offense' do
      # RSpec ignores the block
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            skip 'does something' do
              do_something
            end
            skip 'does something' do
              _1.do_something
            end
          end
        end
      RUBY
    end
  end

  context 'when pending/skip by metadata on example without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          it 'does something', :pending do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
          end
          it 'does something', :skip do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
          it 'does something', pending: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
          end
          it 'does something', skip: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
          it 'does something', :pending do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
            _1
          end
          it 'does something', :skip do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
            _1
          end
        end
      RUBY
    end
  end

  context 'when pending/skip by metadata on example group without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'something', :pending do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
        end
        describe 'something', :skip do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
        end
        describe 'something', pending: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
        end
        describe 'something', skip: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
        end
        describe 'something', :pending do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
          _1
        end
        describe 'something', :skip do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          _1
        end
      RUBY
    end
  end

  context 'when pending/skip without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          pending
          ^^^^^^^ Give the reason for pending.
          skip
          ^^^^ Give the reason for skip.
        end
        RSpec.describe Foo do
          context 'when something' do
            pending
            ^^^^^^^ Give the reason for pending.
          end
          context 'when something' do
            skip
            ^^^^ Give the reason for skip.
          end
        end
        RSpec.describe Foo do
          it 'does something' do
            pending
            ^^^^^^^ Give the reason for pending.
          end
          it 'does something' do
            skip
            ^^^^ Give the reason for skip.
          end
        end
      RUBY
    end
  end

  context 'when pending/skip without reason with other statement' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          before { buzz! }
          pending
          ^^^^^^^ Give the reason for pending.
          skip
          ^^^^ Give the reason for skip.
          context 'when something' do
            let(:foo) { 'bar' }
            pending
            ^^^^^^^ Give the reason for pending.
            skip
            ^^^^ Give the reason for skip.
            it 'does something' do
              do_something
              pending
              ^^^^^^^ Give the reason for pending.
              skip
              ^^^^ Give the reason for skip.
              do_something
            end
          end
        end
      RUBY
    end

    context 'with a numblock' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            pending
            ^^^^^^^ Give the reason for pending.
            skip
            ^^^^ Give the reason for skip.
            _1
            context 'when something' do
              _1
              pending
              ^^^^^^^ Give the reason for pending.
              skip
              ^^^^ Give the reason for skip.
              it 'does something' do
                _1
                skip
                ^^^^ Give the reason for skip.
                pending
                ^^^^^^^ Give the reason for pending.
                _1
              end
            end
          end
        RUBY
      end
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
        RSpec.describe 'Foo' do
          xdescribe 'something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
          xdescribe 'something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
            _1.do_something
          end
        end
      RUBY
    end
  end

  context 'when skipped by top-level example group' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.xdescribe 'something' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
        end
        RSpec.xdescribe 'something' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          _1.do_something
        end
      RUBY
    end
  end

  context 'when skipped by example method' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.describe 'Foo' do
          skip 'does something' do
          ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
          end
          xit 'something' do
          ^^^^^^^^^^^^^^^ Give the reason for xit.
          end
          xit 'something' do
          ^^^^^^^^^^^^^^^ Give the reason for xit.
            _1.do_something
          end
          pending 'does something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
            _1
          end
        end
      RUBY
    end
  end

  context 'when skipped inside an example' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'does something' do
            skip 'does something' do
              do_something
            end
            skip 'does something' do
              _1
            end
          end
        end
      RUBY
    end
  end
end
