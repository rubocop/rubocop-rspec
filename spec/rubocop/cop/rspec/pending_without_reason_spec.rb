# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::PendingWithoutReason do
  context 'when pending by pending step with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          pending 'reason'
        end
      RUBY
    end
  end

  context 'when skipped by skip step with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          skip 'reason'
        end
      RUBY
    end
  end

  context 'when pending by metadata on example with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something', pending: 'reason' do
        end
      RUBY
    end
  end

  context 'when skipped by metadata on example with reason' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something', skip: 'reason' do
        end
      RUBY
    end
  end

  context 'when pending by pending step without reason ' \
          'and not inside example' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :task do
            pending
          end
        end
      RUBY
    end
  end

  context 'when skipped by skip step without reason ' \
          'and not inside example' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :task do
            skip
          end
        end
      RUBY
    end
  end

  context 'when pending with receiver' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          Foo.pending
        end
      RUBY
    end
  end

  context 'when skip with receiver' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          Foo.skip
        end
      RUBY
    end
  end

  context 'when pending is argument of methods' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          expect('foo').to eq pending
          foo(bar, pending)
          foo(bar, pending: pending)
          is_expected.to match_array [foo, pending, bar]
        end
      RUBY
    end
  end

  context 'when skip is argument of methods' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          expect('foo').to eq skip
          foo(bar, skip)
          foo(bar, skip: skip)
          is_expected.to match_array [foo, skip, bar]
        end
      RUBY
    end
  end

  context 'when pending/skip is argument of methods' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          list = [skip, pending]
          foo(list)
        end
      RUBY
    end
  end

  context 'when pending by example method' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        pending 'does something' do
        ^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
        end
      RUBY
    end
  end

  context 'when pending by metadata on example without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        it 'does something', :pending do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for pending.
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
        it 'does something' do
          pending
          ^^^^^^^ Give the reason for pending.
        end
      RUBY
    end
  end

  context 'when pending/skip inside conditional' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        it 'does something' do
          pending if RUBY_VERSION < '3.0'
          if RUBY_VERSION < '3.0'
            skip
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

  context 'when skipped by example method' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        skip 'does something' do
        ^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
        end
      RUBY
    end
  end

  context 'when skipped by metadata on example without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        it 'does something', skip: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Give the reason for skip.
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

  context 'when skipped by skip step without reason' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        it 'does something' do
          skip
          ^^^^ Give the reason for skip.
        end
      RUBY
    end
  end
end
