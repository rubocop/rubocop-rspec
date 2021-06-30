# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MultipleDescribes do
  it 'flags multiple top-level example groups with class and method' do
    expect_offense(<<-RUBY)
      describe MyClass, '.do_something' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      describe MyClass, '.do_something_else' do; end
    RUBY
  end

  it 'flags multiple top-level example groups only with class' do
    expect_offense(<<-RUBY)
      describe MyClass do; end
      ^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      describe MyOtherClass do; end
    RUBY
  end

  it 'flags multiple top-level example groups with an arbitrary argument' do
    expect_offense(<<-RUBY)
      describe 'MyClass' do; end
      ^^^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      describe 'MyOtherClass' do; end
    RUBY
  end

  it 'flags multiple top-level example groups aliases' do
    expect_offense(<<-RUBY)
      example_group MyClass do; end
      ^^^^^^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      feature MyOtherClass do; end
    RUBY
  end

  it 'ignores single top-level example group' do
    expect_no_offenses(<<-RUBY)
      describe MyClass do
      end
    RUBY
  end

  it 'ignores multiple shared example groups' do
    expect_no_offenses(<<-RUBY)
      shared_examples_for 'behaves' do
      end
      shared_examples_for 'misbehaves' do
      end
      describe MyClass do
      end
    RUBY
  end

  context 'when EnforcedStyle is :splitting' do
    let(:cop_config) { { 'EnforcedStyle' => :splitting } }

    it 'check example group in nested example groups' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          describe '#do_something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
            subject { my_class_instance.foo }
          end
        end
      RUBY
    end

    it 'check nested example group in nested example groups' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          shared_examples 'behaves_test' do;end

          describe '#do_something' do
            it_behaves_like 'behaves_test'

            describe 'nested_example_group' do;end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
          end
        end
      RUBY
    end

    it 'check example group when not used rspec matcher' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define :be_a_multiple_of do |expected|
            match do |actual|
              actual % expected == 0
            end
          end

          describe '#do_something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
            it 'does not used rspec matcher' do
              expect(a).to eq(b)
            end
          end
        end
      RUBY
    end

    it 'check example group when not used rspec' \
        'matcher define_negated_matcher' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define_negated_matcher :not_change, :change

          describe '#do_something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
            it 'does not used rspec matcher define_negated_matcher' do
              expect(a).to eq(b)
            end
          end
        end
      RUBY
    end

    it 'check example group when included shared group' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          describe '#do_something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
            shared_examples 'behaves_test' do
              describe 'example_group_in_behaves_test' do;end
              describe 'other_example_group_in_behaves_test' do;end
            end

            it_behaves_like 'behaves_test'
          end

          describe '#do_something_else' do;end
        end
      RUBY
    end

    it 'ignores example group in top level groups' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass, '#do_something' do
          subject { my_class_instance.foo }
        end
        RSpec.describe MyClass, '#do_something_else' do
          subject { my_class_instance.bar }
        end
      RUBY
    end

    it 'ignores example group that uses to when used rspec matcher' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define :be_a_multiple_of do |expected|
            match do |actual|
              actual % expected == 0
            end
          end

          describe '#do_something' do
            it 'used rspec matcher' do
              expect(a).to be_a_multiple_of
            end
          end
        end
      RUBY
    end

    it 'ignores example group that uses not_to when it used rspec matcher' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define :be_a_multiple_of do |expected|
            match do |actual|
              actual % expected == 0
            end
          end

          describe '#do_something' do
            it 'used rspec matcher' do
              expect(a).not_to be_a_multiple_of
            end
          end
        end
      RUBY
    end

    it 'ignores example group when used rspec matcher' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define :be_a_multiple_of do |expected|
            match do |actual|
              actual % expected == 0
            end
          end

          describe '#do_something' do
            describe 'nested_example_group' do
              it 'used rspec matcher' do
                expect('foo').to be_a_multiple_of
              end
            end
          end
        end
      RUBY
    end

    it 'ignores example group when used rspec matcher define_negated_matcher' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define_negated_matcher :not_change, :change

          describe '#do_something' do
            it 'used rspec matcher define_negated_matcher' do
              expect(a).to not_change(Customer, :count).and change(Product, :count).by(1)
            end
          end
        end
      RUBY
    end

    it 'ignores example group when used shared group' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          shared_examples 'behaves_test' do;end

          describe '#do_something' do
            it_behaves_like 'behaves_test'
          end

          describe '#do_something_else' do
            it_behaves_like 'behaves_test'
          end
        end
      RUBY
    end
  end
end
