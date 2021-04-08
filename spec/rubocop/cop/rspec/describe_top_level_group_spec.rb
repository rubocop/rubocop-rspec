# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DescribeTopLevelGroup do
  context 'with CopConfig `Combining`' do
    let(:cop_config) { { 'Combining' => true } }

    it 'check first describe when multiple describe' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass, '#foo' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple describe.
          subject { my_class_instance.foo }
        end

        RSpec.describe MyClass, '#bar' do
          subject { my_class_instance.bar }
        end
      RUBY
    end

    it 'check first describe when multiple describe with nested class' do
      expect_offense(<<-RUBY)
        RSpec.describe User::MyClass, '#foo' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple describe.
          subject { my_class_instance.foo }
        end

        RSpec.describe User::MyClass, '#bar' do
          subject { my_class_instance.bar }
        end
      RUBY
    end

    it 'check first describe when multiple describe with no method' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
        ^^^^^^^^^^^^^^^^^^^^^^ Combine multiple describe.
          describe '#foo' do
            subject { my_class_instance.foo }
          end

          describe '#bar' do
            subject { my_class_instance.bar }
          end
        end

        RSpec.describe MyClass do
          describe '#hoge' do
            subject { my_class_instance.hoge }
          end
        end
      RUBY
    end

    it 'skip when single describe' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass do
          describe '#foo' do
            subject { my_class_instance.foo }
          end

          describe '#bar' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'skip when single describe with no child describe' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe MyClass, '#foo' do
          subject { my_class_instance.foo }
        end
      RUBY
    end

    it 'skip when multiple describe with no class' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe 'sample' do
          subject { my_class_instance.foo }
        end

        RSpec.describe 'sample2' do
          subject { my_class_instance.bar }
        end
      RUBY
    end
  end

  context 'with CopConfig `Splitting`' do
    let(:cop_config) { { 'Splitting' => true } }

    it 'check first describe of child when next describe' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass do
          describe '#foo' do
          ^^^^^^^^^^^^^^^ Split multiple describe.
            subject { my_class_instance.foo }
          end

          describe '#bar' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'check first describe of child when next describe with nested class' do
      expect_offense(<<-RUBY)
        RSpec.describe User::MyClass do
          describe '#foo' do
          ^^^^^^^^^^^^^^^ Split multiple describe.
            subject { my_class_instance.foo }
          end

          describe '#bar' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'check first describe of child when next describe with type' do
      expect_offense(<<-RUBY)
        RSpec.describe MyClass type: :model do
          describe '#foo' do
          ^^^^^^^^^^^^^^^ Split multiple describe.
            subject { my_class_instance.foo }
          end

          describe '#bar' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'check first describe of child when child describe' do
      expect_offense(<<-RUBY)
        describe ProjectsController, type: :controller do
          describe 'GET index' do
          ^^^^^^^^^^^^^^^^^^^^ Split multiple describe.
            describe 'test' do; end
          end

          describe 'POST create mass assignment' do; end

          describe 'POST claim' do; end
        end
      RUBY
    end

    it 'check first describe of child after require' do
      expect_offense(<<-RUBY)
        require 'rails_helper'

        RSpec.describe MyClass do
          let(:project) { create :project }

          describe '#foo' do
          ^^^^^^^^^^^^^^^ Split multiple describe.
            subject { my_class_instance.foo }
          end

          describe '#bar' do
            subject { my_class_instance.bar }
          end
        end
      RUBY
    end

    it 'skips when multiple describe' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe MyClass, '#foo' do
          subject { my_class_instance.foo }
        end

        RSpec.describe MyClass, '#bar' do
          subject { my_class_instance.bar }
        end
      RUBY
    end

    it 'skips single describe' do
      expect_no_offenses(<<-RUBY)
        describe "something" do
          it "does something that passes" do
            1.should eq(1)
          end

          it "does something that fails" do
            1.should eq(2)
          end
        end
      RUBY
    end
  end
end
