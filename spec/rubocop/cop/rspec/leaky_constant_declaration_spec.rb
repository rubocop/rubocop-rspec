# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeakyConstantDeclaration do
  describe 'constant assignment' do
    it 'flags inside an example group' do
      expect_offense(<<~RUBY)
        describe SomeClass do
          CONSTANT = "Accessible as ::CONSTANT".freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub constant instead of declaring explicitly.
        end
      RUBY
    end

    it 'flags inside shared example group' do
      expect_offense(<<~RUBY)
        RSpec.shared_examples 'shared example' do
          CONSTANT = "Accessible as ::CONSTANT".freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub constant instead of declaring explicitly.
        end
      RUBY
    end

    it 'flags inside an example' do
      expect_offense(<<~RUBY)
        describe SomeClass do
          specify do
            CONSTANT = "Accessible as ::CONSTANT".freeze
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub constant instead of declaring explicitly.
          end
        end
      RUBY
    end

    it 'ignores constant defined on the example group' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          self::CONSTANT = "Accessible as self.class::CONSTANT".freeze
        end
      RUBY
    end

    it 'ignores constant defined in an explicit namespace' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          Foo::CONSTANT = "Accessible as Foo::CONSTANT".freeze
        end
      RUBY
    end

    it 'ignores classes defined explicitly in the global namespace' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          ::CONSTANT = "Accessible as ::CONSTANT".freeze
        end
      RUBY
    end

    it 'ignores outside of example/shared group' do
      expect_no_offenses(<<~RUBY)
        factory :some_class do
          CONSTANT = "Accessible as ::CONSTANT".freeze
        end
      RUBY
    end
  end

  describe 'class defined' do
    it 'flags inside an example group' do
      expect_offense(<<~RUBY)
        describe SomeClass do
          class DummyClass < described_class
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class constant instead of declaring explicitly.
          end
        end
      RUBY
    end

    it 'ignores anonymous classes' do
      expect_no_offenses(<<~RUBY)
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

    it 'ignores classes defined on the example group' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          class self::DummyClass
          end
        end
      RUBY
    end

    it 'ignores classes defined in an explicit namespace' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          class Foo::DummyClass
          end
        end
      RUBY
    end

    it 'ignores classes defined explicitly in the global namespace' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          class ::DummyClass
          end
        end
      RUBY
    end

    it 'ignores outside of example/shared group' do
      expect_no_offenses(<<~RUBY)
        class DummyClass
        end
      RUBY
    end
  end

  describe 'module defined' do
    it 'flags inside an example group' do
      expect_offense(<<~RUBY)
        describe SomeClass do
          module DummyModule
          ^^^^^^^^^^^^^^^^^^ Stub module constant instead of declaring explicitly.
          end
        end
      RUBY
    end

    it 'ignores modules defined on the example group' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          module self::DummyModule
          end
        end
      RUBY
    end

    it 'ignores modules defined in an explicit namespace' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          module Foo::DummyModule
          end
        end
      RUBY
    end

    it 'ignores modules defined explicitly in the global namespace' do
      expect_no_offenses(<<~RUBY)
        describe SomeClass do
          module ::DummyModule
          end
        end
      RUBY
    end

    it 'ignores outside of example/shared group' do
      expect_no_offenses(<<~RUBY)
        module Dummymodule
        end
      RUBY
    end
  end
end
