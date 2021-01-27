# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::OrderedHooks do
  it 'detects `before` after `around`' do
    expect_offense(<<~RUBY)
      describe "hooks order" do
        around do |example|
          example.call
        end

        before do
        ^^^^^^ `before` is supposed to appear before `around` at line 2.
          run_setup
        end
      end
    RUBY
  end

  it 'detects `before` after `after`' do
    expect_offense(<<~RUBY)
      describe "hooks order" do
        after do
          run_teardown
        end

        before do
        ^^^^^^ `before` is supposed to appear before `after` at line 2.
          run_setup
        end
      end
    RUBY
  end

  it 'detects `around` after `after`' do
    expect_offense(<<~RUBY)
      describe "hooks order" do
        after do
          run_teardown
        end

        around do |example|
        ^^^^^^ `around` is supposed to appear before `after` at line 2.
          example.run
        end
      end
    RUBY
  end

  context 'with multiple hooks' do
    it 'reports each violation independently' do
      expect_offense(<<~RUBY)
        describe "hooks order" do
          after { cleanup }

          around do |example|
          ^^^^^^ `around` is supposed to appear before `after` at line 2.
            example.call
          end

          before { some_preparation }
          ^^^^^^ `before` is supposed to appear before `around` at line 4.

          before { some_other_preparation }

          after { more_cleanup }

          before { more_preparation }
          ^^^^^^ `before` is supposed to appear before `after` at line 12.
        end
      RUBY
    end
  end

  context 'with scoped hooks' do
    context 'when hook is before' do
      it 'detects `suite` after `context`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            before(:context) { init_factories }
            before(:suite) { global_setup }
            ^^^^^^^^^^^^^^ `before(:suite)` is supposed to appear before `before(:context)` at line 2.
          end
        RUBY
      end

      it 'detects `suite` after `each`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            before(:each) { init_data }
            before(:suite) { global_setup }
            ^^^^^^^^^^^^^^ `before(:suite)` is supposed to appear before `before(:each)` at line 2.
          end
        RUBY
      end

      it 'detects `context` after `each`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            before(:each) { init_data }
            before(:context) { setup }
            ^^^^^^^^^^^^^^^^ `before(:context)` is supposed to appear before `before(:each)` at line 2.
          end
        RUBY
      end

      it 'accepts `example` and `each`' do
        expect_no_offenses(<<~RUBY)
          describe "hooks order" do
            before { setup1 }
            before(:each) { setup2 }
            before(:example) { setup3 }
          end
        RUBY
      end

      it 'detects `context` after `example`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            before(:example) { init_data }
            before(:context) { setup }
            ^^^^^^^^^^^^^^^^ `before(:context)` is supposed to appear before `before(:example)` at line 2.
          end
        RUBY
      end
    end

    context 'when hook is after' do
      it 'detects `context` after `suite`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            after(:suite) { global_teardown }
            after(:context) { teardown }
            ^^^^^^^^^^^^^^^ `after(:context)` is supposed to appear before `after(:suite)` at line 2.
          end
        RUBY
      end

      it 'detects `each` after `suite`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            after(:suite) { global_teardown }
            after(:each) { teardown }
            ^^^^^^^^^^^^ `after(:each)` is supposed to appear before `after(:suite)` at line 2.
          end
        RUBY
      end

      it 'detects `each` after `context`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            after(:context) { teardown }
            after(:each) { cleanup }
            ^^^^^^^^^^^^ `after(:each)` is supposed to appear before `after(:context)` at line 2.
          end
        RUBY
      end

      it 'accepts `example` and `each`' do
        expect_no_offenses(<<~RUBY)
          describe "hooks order" do
            after { setup1 }
            after(:each) { setup2 }
            after(:example) { setup3 }
          end
        RUBY
      end

      it 'detects `example` after `context`' do
        expect_offense(<<~RUBY)
          describe "hooks order" do
            after(:context) { cleanup }
            after(:example) { teardown }
            ^^^^^^^^^^^^^^^ `after(:example)` is supposed to appear before `after(:context)` at line 2.
          end
        RUBY
      end
    end
  end

  it 'accepts hooks in order' do
    expect_no_offenses(<<~RUBY)
      desribe "correctly ordered hooks" do
        before(:suite) do
          run_global_setup
        end

        before(:context) do
          run_context_setup
        end

        before(:example) do
          run_setup
        end

        around(:example) do |example|
          example.run
        end

        after(:example) do
          run_teardown
        end

        after(:context) do
          run_context_teardown
        end

        after(:suite) do
          run_global_teardown
        end
      end
    RUBY
  end
end
