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

  context 'with CopConfig `Splitting' do
    let(:cop_config) { { 'Splitting' => true } }

    it 'check first describe in nested describe' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          describe '#do_something' do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
            subject { my_class_instance.foo }
          end
        end
      RUBY
    end

    it 'check first describe in each nested describe' do
      expect_offense(<<-RUBY)
        describe MyClassController, type: :controller do
          describe 'do_something' do
          ^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
            describe 'do_something_in_describe' do; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use nested describe - try to split them.
          end
          describe 'do_something_else' do; end
        end
      RUBY
    end

    it 'ignores describe in top level groups' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass, '#do_something' do
          subject { my_class_instance.foo }
        end
        RSpec.describe MyClass, '#do_something_else' do
          subject { my_class_instance.bar }
        end
      RUBY
    end

    it 'ignores describe when rspec matcher exists' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          RSpec::Matchers.define :be_a_multiple_of do |expected|
            match do |actual|
              actual % expected == 0
            end
          end

          describe '#do_something' do
            subject { my_class_instance.foo }
          end

          describe '#do_something_else' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'ignores describe when shared example group exists' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          shared_examples 'behaves' do;end

          describe '#do_something' do
            subject { my_class_instance.foo }
          end

          describe '#do_something_else' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'ignores describe when shared example for group exists' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          shared_examples_for 'behaves' do;end

          describe '#do_something' do
            subject { my_class_instance.foo }
          end

          describe '#do_something_else' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'ignores describe when shared context group exists' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          shared_context 'behaves' do;end

          describe '#do_something' do
            subject { my_class_instance.foo }
          end

          describe '#do_something_else' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'ignores describe when shared context group includes describe' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          RSpec.shared_examples 'behaves' do
            describe '#do_something_in_behaves' do;end
            describe '#do_something_else_in_behaves' do;end
          end

          describe '#do_something' do;end
          describe '#do_something_else' do;end
        end
      RUBY
    end

    it 'ignores describe when describe includes shared example group' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          describe '#foo' do
            RSpec.shared_examples 'behaves' do
              describe '#do_something_in_behaves' do;end
              describe '#do_something_else_in_behaves' do;end
            end
          end
          describe '#do_something' do;end
        end
      RUBY
    end
  end
end
