# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ScatteredSetup do
  it 'flags multiple hooks in the same example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        before { bar }
        before { baz }
        ^^^^^^^^^^^^^^ Do not define multiple `before` hooks in the same example group (also defined on line 2).
      end
    RUBY

    expect_correction(<<~RUBY)
      describe Foo do
        before { bar

      baz }
      end
    RUBY
  end

  it 'flags multiple hooks of the same scope with different symbols' do
    expect_offense(<<~RUBY)
      describe Foo do
        after { bar }
        after(:each) { baz }
        ^^^^^^^^^^^^^^^^^^^^ Do not define multiple `after` hooks in the same example group (also defined on line 2).
        after(:example) { baz }
        ^^^^^^^^^^^^^^^^^^^^^^^ Do not define multiple `after` hooks in the same example group (also defined on line 2).
      end
    RUBY

    expect_correction(<<~RUBY)
      describe Foo do
        after { bar

      baz

      baz }
      end
    RUBY
  end

  it 'flags multiple before(:all) hooks in the same example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        before(:all) { bar }
        before(:all) { baz }
        ^^^^^^^^^^^^^^^^^^^^ Do not define multiple `before` hooks in the same example group (also defined on line 2).
      end
    RUBY

    expect_correction(<<~RUBY)
      describe Foo do
        before(:all) { bar

      baz }
      end
    RUBY
  end

  it 'ignores different hooks' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before { bar }
        after { baz }
        around { qux }
      end
    RUBY
  end

  it 'ignores different hook types' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before { bar }
        before(:all) { baz }
        before(:suite) { baz }
      end
    RUBY
  end

  it 'ignores hooks in different example groups' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before { bar }

        describe '.baz' do
          before { baz }
        end
      end
    RUBY
  end

  it 'ignores hooks in different shared contexts' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        shared_context 'one' do
          before { bar }
        end

        shared_context 'two' do
          before { baz }
        end
      end
    RUBY
  end

  it 'ignores similar method names inside of examples' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before { bar }

        it 'uses an instance method called before' do
          expect(before { tricky }).to_not confuse_rubocop_rspec
        end
      end
    RUBY
  end

  it 'ignores hooks with different metadata' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before(:example) { foo }
        before(:example, :special_case) { bar }
      end
    RUBY
  end

  it 'flags hooks with similar metadata' do
    expect_offense(<<~RUBY)
      describe Foo do
        before(:each, :special_case) { foo }
        before(:example, :special_case) { bar }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define multiple `before` hooks in the same example group (also defined on line 2).
        before(:example, special_case: true) { bar }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define multiple `before` hooks in the same example group (also defined on line 2).
        before(special_case: true) { bar }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define multiple `before` hooks in the same example group (also defined on line 2).
        before(:example, special_case: false) { bar }
      end
    RUBY

    expect_correction(<<~RUBY)
      describe Foo do
        before(:each, :special_case) { foo

      bar

      bar

      bar }
        before(:example, special_case: false) { bar }
      end
    RUBY
  end

  context 'with multiple `around`' do
    it 'registers offense without autocorrection' do
      expect_offense(<<~RUBY)
        describe Foo do
          around do |example|
            a
            example.run
            b
          end

          around do |example|
          ^^^^^^^^^^^^^^^^^^^ Do not define multiple `around` hooks in the same example group (also defined on line 2).
            c
            example.run
            d
          end
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'with `let!` between multiple `before`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe Foo do
          before { a }
          let!(:b) { 1 }
          before { c }
          ^^^^^^^^^^^^ Do not define multiple `before` hooks in the same example group (also defined on line 2).
        end
      RUBY

      expect_correction(<<~RUBY)
        describe Foo do
          before { a

        c }
          let!(:b) { 1 }
        end
      RUBY
    end
  end
end
