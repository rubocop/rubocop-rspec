# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedIncludeExample do
  shared_examples 'detect repeated include examples' do |include_method|
    context "with include method: #{include_method}" do
      context 'without parameters' do
        it "registers an offense for repeated #{include_method}" do
          expect_offense(<<~RUBY, include_method: include_method)
            describe 'foo' do
              %{include_method} 'an x'
              ^{include_method}^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [4]
              %{include_method} 'something else'
              %{include_method} 'an x'
              ^{include_method}^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2]
            end
          RUBY
          expect_no_corrections
        end

        it "registers an offense for repeated #{include_method} " \
          'with parentheses' do
          expect_offense(<<~RUBY, include_method: include_method)
            describe 'foo' do
              %{include_method}('an x')
              ^{include_method}^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [3]
              %{include_method}('an x')
              ^{include_method}^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2]
            end
          RUBY
          expect_no_corrections
        end

        it "allows #{include_method} with different names" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method} 'an x'
              #{include_method} 'a y'
            end
          RUBY
        end

        it "allows repeated #{include_method} in separate example groups" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method} 'an x'
            end

            describe 'bar' do
              #{include_method} 'an x'
            end
          RUBY
        end
      end

      context 'with parameters' do
        it "registers an offense for repeated #{include_method}" do
          expect_offense(<<~RUBY, include_method: include_method)
            describe 'foo' do
              %{include_method} 'an x', 'y'
              ^{include_method}^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [4]
              %{include_method} 'an x', 'other'
              %{include_method} 'an x', 'y'
              ^{include_method}^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2]
            end
          RUBY
          expect_no_corrections
        end

        it "registers an offense for repeated #{include_method} " \
          'with parentheses' do
          expect_offense(<<~RUBY, include_method: include_method)
            describe 'foo' do
              %{include_method}('an x', 'y')
              ^{include_method}^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [3]
              %{include_method}('an x', 'y')
              ^{include_method}^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2]
            end
          RUBY
          expect_no_corrections
        end

        it "registers an offense for repeated #{include_method} " \
           'with composite literal / const parameters' do
          expect_offense(<<~RUBY, include_method: include_method)
            describe 'foo' do
              %{include_method}('something', [1, 'b', :c, D, { e: :f }, nil])
              ^{include_method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'something' on line(s) [3]
              %{include_method}('something', [1, 'b', :c, D, { e: :f }, nil])
              ^{include_method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'something' on line(s) [2]
            end
          RUBY
        end

        it "accepts repeated #{include_method} with different parameters" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method} 'an x', 'y'
              #{include_method} 'an x', 'z'
              #{include_method} 'an x'
              #{include_method} 'an x', 'y', 'z'
            end
          RUBY
        end

        it "accepts repeated #{include_method} with different parameters " \
          'with parentheses' do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method}('an x', 'y')
              #{include_method}('an x', 'z')
              #{include_method}('an x')
              #{include_method}('an x', 'y', 'z')
            end
          RUBY
        end

        it "allows repeated #{include_method} with variable arguments" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method} 'one', foo
              #{include_method} 'one', foo

              #{include_method} 'two', @foo
              #{include_method} 'two', @foo

              #{include_method} 'two', @@foo
              #{include_method} 'two', @@foo

              #{include_method} 'two', $foo
              #{include_method} 'two', $foo
            end
          RUBY
        end

        it "allows repeated #{include_method} with block" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method} 'one' do
                'something'
              end
              #{include_method} 'one' do
                'something'
              end

              #{include_method}('two') { rand }
              #{include_method}('two') { rand }
            end
          RUBY
        end

        it "allows repeated #{include_method} with passed block" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method}('one', &block)
              #{include_method}('one', &block)

              #{include_method}('two', &:method)
              #{include_method}('two', &:method)
            end
          RUBY
        end

        it "allows repeated #{include_method} in separate example groups" do
          expect_no_offenses(<<~RUBY)
            describe 'foo' do
              #{include_method} 'an x', 'y'
            end

            describe 'bar' do
              #{include_method} 'an x', 'y'
            end
          RUBY
        end
      end
    end
  end

  it_behaves_like 'detect repeated include examples', 'include_examples'
  it_behaves_like 'detect repeated include examples', 'it_behaves_like'
  it_behaves_like 'detect repeated include examples', 'it_should_behave_like'

  context 'with mixed include methods' do
    it 'registers an offense for repeated includes with no parameters' do
      expect_offense(<<~RUBY)
        describe 'foo' do
          include_examples 'an x'
          ^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [3, 4]
          it_behaves_like 'an x'
          ^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2, 4]
          it_should_behave_like('an x')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2, 3]
        end
      RUBY
      expect_no_corrections
    end

    it 'allows includes of different shared_examples' do
      expect_no_offenses(<<~RUBY)
        describe 'foo' do
          include_examples 'one'
          it_behaves_like 'two'
          it_should_behave_like 'three'
        end
      RUBY
    end

    it 'registers an offense for repeated includes with same parameters' do
      expect_offense(<<~RUBY)
        describe 'foo' do
          include_examples 'an x', 'y'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [3, 4]
          it_behaves_like 'an x', 'y'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2, 4]
          it_should_behave_like('an x', 'y')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated include of shared_examples 'an x' on line(s) [2, 3]
        end
      RUBY
      expect_no_corrections
    end

    it 'allows includes with different parameters' do
      expect_no_offenses(<<~RUBY)
        describe 'foo' do
          include_examples 'something', 'x'
          it_behaves_like 'something', 'y'
          it_should_behave_like 'something', 42
        end
      RUBY
    end
  end
end
