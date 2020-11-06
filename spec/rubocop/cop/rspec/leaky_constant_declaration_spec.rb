# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeakyConstantDeclaration do
  describe 'constant assignment' do
    it 'flags inside an example group' do
      expect_offense(<<-RUBY)
        describe SomeClass do
          CONSTANT = "Accessible as ::CONSTANT".freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub constant instead of declaring explicitly.
        end
      RUBY
    end

    it 'flags inside shared example group' do
      expect_offense(<<-RUBY)
        RSpec.shared_examples 'shared example' do
          CONSTANT = "Accessible as ::CONSTANT".freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub constant instead of declaring explicitly.
        end
      RUBY
    end

    it 'flags inside an example' do
      expect_offense(<<-RUBY)
        describe SomeClass do
          specify do
            CONSTANT = "Accessible as ::CONSTANT".freeze
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub constant instead of declaring explicitly.
          end
        end
      RUBY
    end

    it 'ignores outside of example/shared group' do
      expect_no_offenses(<<-RUBY)
        factory :some_class do
          CONSTANT = "Accessible as ::CONSTANT".freeze
        end
      RUBY
    end
  end

  describe 'class defined' do
    it 'flags inside an example group' do
      expect_offense(<<-RUBY)
        describe SomeClass do
          class DummyClass < described_class
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class constant instead of declaring explicitly.
          end
        end
      RUBY
    end

    it 'ignores anonymous classes' do
      expect_no_offenses(<<-RUBY)
        describe SomeClass do
          let(:dummy_playbook) do
            Class.new do
              def method
              end
            end
          end
         end
      RUBY
    end

    it 'flags namespaced class' do
      expect_offense(<<-RUBY)
        describe SomeClass do
          class SomeModule::AnotherModule::DummyClass
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class constant instead of declaring explicitly.
          end
        end
      RUBY
    end
  end

  describe 'module defined' do
    it 'flags inside an example group' do
      expect_offense(<<-RUBY)
        describe SomeClass do
          module DummyModule
          ^^^^^^^^^^^^^^^^^^ Stub module constant instead of declaring explicitly.
          end
        end
      RUBY
    end
  end
end
