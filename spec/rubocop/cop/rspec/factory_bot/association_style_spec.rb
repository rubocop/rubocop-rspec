# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::AssociationStyle do
  def inspected_source_filename
    'spec/factories.rb'
  end

  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'when EnforcedStyle is :implicit' do
    let(:enforced_style) { :implicit }

    context 'when factory block is empty' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          factory :user do
          end
        RUBY
      end
    end

    context 'with when factory has no block' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          factory :user
        RUBY
      end
    end

    context 'when implicit style is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          factory :article do
            user
          end
        RUBY
      end
    end

    context 'when `association` is called in attribute block' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          factory :article do
            author do
              association :user
            end
          end
        RUBY
      end
    end

    context 'when `association` has only 1 argument' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :user
            ^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            user
          end
        RUBY
      end
    end

    context 'when `association` is called in trait block' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            trait :with_user do
              association :user
              ^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            trait :with_user do
              user
            end
          end
        RUBY
      end
    end

    context 'when `association` is called with trait' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :user, :admin
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            user factory: %i[user admin]
          end
        RUBY
      end
    end

    context 'when `association` is called with factory option' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :author, factory: :user
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            author factory: %i[user]
          end
        RUBY
      end
    end

    context 'when `association` is called with array factory option' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :author, factory: %i[user]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            author factory: %i[user]
          end
        RUBY
      end
    end

    context 'when `association` is called with trait arguments and factory' \
            'option' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :author, :admin, factory: :user
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            author factory: %i[user admin]
          end
        RUBY
      end
    end

    context 'when `association` is called with traits option' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :author, traits: %i[admin]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            author factory: %i[author admin]
          end
        RUBY
      end
    end

    context 'when `association` is called with factory and traits options' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :author, factory: :user, traits: [:admin]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            author factory: %i[user admin]
          end
        RUBY
      end
    end

    context 'when `association` is called with trait arguments and factory' \
            'and traits options' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            association :author, :active, factory: :user, traits: [:admin]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use implicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            author factory: %i[user active admin]
          end
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is :explicit' do
    let(:enforced_style) { :explicit }

    context 'when explicit style is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          factory :article do
            association :user
          end
        RUBY
      end
    end

    context 'when implicit association is used without any arguments' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            user
            ^^^^ Use explicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            association :user
          end
        RUBY
      end
    end

    context 'when implicit association is used with arguments' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            author factory: :user
            ^^^^^^^^^^^^^^^^^^^^^ Use explicit style to define associations.
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            association :author, factory: :user
          end
        RUBY
      end
    end

    context 'when default non implicit association method name is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          factory :article do
            skip_create
          end
        RUBY
      end
    end

    context 'when custom non implicit association method name is used' do
      let(:cop_config) do
        { 'NonImplicitAssociationMethods' => %w[email] }
      end

      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          sequence(:email) { |n| "person#{n}@example.com" }

          factory :user do
            email

            skip_create
          end
        RUBY
      end
    end

    context 'when implicit association is called in trait block' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          factory :article do
            trait :with_user do
              user
              ^^^^ Use explicit style to define associations.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          factory :article do
            trait :with_user do
              association :user
            end
          end
        RUBY
      end
    end
  end
end
