# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyHook do
  context 'with `before` hook' do
    it 'detects offense for empty `before`' do
      expect_offense(<<~RUBY)
        before {}
        ^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'detects offense for empty `before` with :each scope' do
      expect_offense(<<~RUBY)
        before(:each) {}
        ^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'detects offense for empty `before` with :example scope' do
      expect_offense(<<~RUBY)
        before(:example) {}
        ^^^^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'detects offense for empty `before` with :context scope' do
      expect_offense(<<~RUBY)
        before(:context) {}
        ^^^^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'detects offense for empty `before` with :all scope' do
      expect_offense(<<~RUBY)
        before(:all) {}
        ^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'detects offense for empty `before` with :suite scope' do
      expect_offense(<<~RUBY)
        before(:suite) {}
        ^^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `before` hook' do
      expect_no_offenses(<<~RUBY)
        before { create_users }
      RUBY
    end

    it 'accepts multiline `before` hook' do
      expect_no_offenses(<<~RUBY)
        before(:all) do
          create_users
          create_products
        end
      RUBY
    end

    it 'autocorrects `before` with semicolon' do
      expect_offense(<<~RUBY)
        before {}; after { clean_up(:foo) }
        ^^^^^^ Empty hook detected.
      RUBY

      expect_correction(<<~RUBY)
        ; after { clean_up(:foo) }
      RUBY
    end
  end

  context 'with `after` hook' do
    it 'detects offense for empty `after`' do
      expect_offense(<<~RUBY)
        after {}
        ^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `after` hook' do
      expect_no_offenses(<<~RUBY)
        after { cleanup_users }
      RUBY
    end

    it 'accepts multiline `after` hook' do
      expect_no_offenses(<<~RUBY)
        after(:suite) do
          cleanup_users
          cleanup_products
        end
      RUBY
    end
  end

  context 'with `around` hook' do
    it 'detects offense for empty `around`' do
      expect_offense(<<~RUBY)
        around {}
        ^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `around` hook' do
      expect_no_offenses(<<~RUBY)
        around { yield }
      RUBY
    end

    it 'accepts multiline `around` hook' do
      expect_no_offenses(<<~RUBY)
        around(:suite) do
          setup_users
          yield
        end
      RUBY
    end
  end

  context 'with `prepend_before` hook' do
    it 'detects offense for empty `prepend_before`' do
      expect_offense(<<~RUBY)
        prepend_before {}
        ^^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `prepend_before` hook' do
      expect_no_offenses(<<~RUBY)
        prepend_before { create_users }
      RUBY
    end

    it 'accepts multiline `prepend_before` hook' do
      expect_no_offenses(<<~RUBY)
        prepend_before(:all) do
          create_users
          create_products
        end
      RUBY
    end
  end

  context 'with `append_before` hook' do
    it 'detects offense for empty `append_before`' do
      expect_offense(<<~RUBY)
        append_before {}
        ^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `append_before` hook' do
      expect_no_offenses(<<~RUBY)
        append_before { create_users }
      RUBY
    end

    it 'accepts multiline `append_before` hook' do
      expect_no_offenses(<<~RUBY)
        append_before(:each) do
          create_users
          create_products
        end
      RUBY
    end
  end

  context 'with `prepend_after` hook' do
    it 'detects offense for empty `prepend_after`' do
      expect_offense(<<~RUBY)
        prepend_after {}
        ^^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `prepend_after` hook' do
      expect_no_offenses(<<~RUBY)
        prepend_after { cleanup_users }
      RUBY
    end

    it 'accepts multiline `prepend_after` hook' do
      expect_no_offenses(<<~RUBY)
        prepend_after(:all) do
          cleanup_users
          cleanup_products
        end
      RUBY
    end
  end

  context 'with `append_after` hook' do
    it 'detects offense for empty `append_after`' do
      expect_offense(<<~RUBY)
        append_after {}
        ^^^^^^^^^^^^ Empty hook detected.
      RUBY

      expect_correction('')
    end

    it 'accepts non-empty `append_after` hook' do
      expect_no_offenses(<<~RUBY)
        append_after { cleanup_users }
      RUBY
    end

    it 'accepts multiline `append_after` hook' do
      expect_no_offenses(<<~RUBY)
        append_after(:all) do
          cleanup_users
          cleanup_products
        end
      RUBY
    end
  end
end
