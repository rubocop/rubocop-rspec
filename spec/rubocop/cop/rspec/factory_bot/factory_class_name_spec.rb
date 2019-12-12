# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::FactoryClassName do
  subject(:cop) { described_class.new }

  context 'when passing block' do
    it 'flags passing a class' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo do
                             ^^^ Pass 'Foo' string instead of `Foo` constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: 'Foo' do
        end
      RUBY
    end

    it 'flags passing a class from global namespace' do
      expect_offense(<<~RUBY)
        factory :foo, class: ::Foo do
                             ^^^^^ Pass 'Foo' string instead of `Foo` constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: '::Foo' do
        end
      RUBY
    end

    it 'flags passing a subclass' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo::Bar do
                             ^^^^^^^^ Pass 'Foo::Bar' string instead of `Foo::Bar` constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: 'Foo::Bar' do
        end
      RUBY
    end

    it 'ignores passing class name' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: 'Foo' do
        end
      RUBY
    end

    it 'ignores passing Hash' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: Hash do
        end
      RUBY
    end

    it 'ignores passing OpenStruct' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: OpenStruct do
        end
      RUBY
    end
  end

  context 'when not passing block' do
    it 'flags passing a class' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo
                             ^^^ Pass 'Foo' string instead of `Foo` constant.
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: 'Foo'
      RUBY
    end

    it 'ignores passing class name' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: 'Foo'
      RUBY
    end
  end
end
