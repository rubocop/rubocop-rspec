# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::FactoryAssociation,
               :config do

  let(:message) do
    "Use #{association_name} { build(:#{factory_name}) } instead"
  end

  context 'when association name and factory name are the same' do
    let(:association_name) { 'foo' }
    let(:factory_name) { 'foo' }

    it 'autocorrects method' do
      expect_offense(<<~RUBY)
        association :foo
        ^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:foo) }
      RUBY
    end

    it 'autocorrects inline method' do
      expect_offense(<<~RUBY)
        foo { association :foo }
        ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:foo) }
      RUBY
    end

    it 'autocorrects method with explicit factory' do
      expect_offense(<<~RUBY)
        association :foo, factory: :foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:foo) }
      RUBY
    end

    it 'autocorrects method in new line' do
      expect_offense(<<~RUBY)
        association :foo,
        ^^^^^^^^^^^^^^^^^ #{message}
                    factory: :foo
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:foo) }
      RUBY
    end

    it 'allows using build' do
      expect_no_offenses(<<~RUBY)
        foo { build(:foo) }
      RUBY
    end
  end

  context 'when association name and factory name differ' do
    let(:association_name) { 'foo' }
    let(:factory_name) { 'bar' }

    it 'autocorrects inline method' do
      expect_offense(<<~RUBY)
        foo { association :bar }
        ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:bar) }
      RUBY
    end

    it 'autocorrects method with explicit factory' do
      expect_offense(<<~RUBY)
        association :foo, factory: :bar
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:bar) }
      RUBY
    end

    it 'autocorrects method in new line' do
      expect_offense(<<~RUBY)
        association :foo,
        ^^^^^^^^^^^^^^^^^ #{message}
                    factory: :bar
      RUBY

      expect_correction(<<~RUBY)
        foo { build(:bar) }
      RUBY
    end

    it 'autocorrects using build' do
      expect_no_offenses(<<~RUBY)
        foo { build(:bar) }
      RUBY
    end
  end
end
