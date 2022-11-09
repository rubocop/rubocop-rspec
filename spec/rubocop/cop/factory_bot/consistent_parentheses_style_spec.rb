# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::ConsistentParenthesesStyle do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'when EnforcedStyle is :enforce_parentheses' do
    let(:enforced_style) { :require_parentheses }

    context 'with create' do
      it 'flags the call to use parentheses' do
        expect_offense(<<~RUBY)
          create :user
          ^^^^^^ Prefer method call with parentheses
        RUBY

        expect_correction(<<~RUBY)
          create(:user)
        RUBY
      end
    end

    context 'with multiline method calls' do
      it 'expects parentheses around multiline call' do
        expect_offense(<<~RUBY)
          create :user,
          ^^^^^^ Prefer method call with parentheses
            username: "PETER",
            peter: "USERNAME"
        RUBY

        expect_correction(<<~RUBY)
          create(:user,
            username: "PETER",
            peter: "USERNAME")
        RUBY
      end
    end

    context 'with build' do
      it 'flags the call to use parentheses' do
        expect_offense(<<~RUBY)
          build :user
          ^^^^^ Prefer method call with parentheses
        RUBY

        expect_correction(<<~RUBY)
          build(:user)
        RUBY
      end
    end

    context 'with mixed tests' do
      it 'flags the call to use parentheses' do
        expect_offense(<<~RUBY)
          build_list :user, 10
          ^^^^^^^^^^ Prefer method call with parentheses
          build_list "user", 10
          ^^^^^^^^^^ Prefer method call with parentheses
          create_list :user, 10
          ^^^^^^^^^^^ Prefer method call with parentheses
          build_stubbed :user
          ^^^^^^^^^^^^^ Prefer method call with parentheses
          build_stubbed_list :user, 10
          ^^^^^^^^^^^^^^^^^^ Prefer method call with parentheses
          build factory
          ^^^^^ Prefer method call with parentheses
        RUBY

        expect_correction(<<~RUBY)
          build_list(:user, 10)
          build_list("user", 10)
          create_list(:user, 10)
          build_stubbed(:user)
          build_stubbed_list(:user, 10)
          build(factory)
        RUBY
      end
    end

    context 'with nested calling' do
      it 'flags the call to use parentheses' do
        expect_offense(<<~RUBY)
          build :user, build(:yester)
          ^^^^^ Prefer method call with parentheses
        RUBY

        expect_correction(<<~RUBY)
          build(:user, build(:yester))
        RUBY
      end

      it 'works in a bigger context' do
        expect_offense(<<~RUBY)
          context 'with context' do
            let(:build) { create :user, build(:user) }
                          ^^^^^^ Prefer method call with parentheses

            it 'test in test' do
              user = create :user, first: name, peter: miller
                     ^^^^^^ Prefer method call with parentheses
            end

            let(:build) { create :user, build(:user, create(:user, create(:first_name))) }
                          ^^^^^^ Prefer method call with parentheses
          end
        RUBY

        expect_correction(<<~RUBY)
          context 'with context' do
            let(:build) { create(:user, build(:user)) }

            it 'test in test' do
              user = create(:user, first: name, peter: miller)
            end

            let(:build) { create(:user, build(:user, create(:user, create(:first_name)))) }
          end
        RUBY
      end
    end

    context 'with already valid usage of parentheses' do
      it 'does not flag as invalid - create' do
        expect_no_offenses(<<~RUBY)
          create(:user)
        RUBY
      end

      it 'does not flag as invalid - build' do
        expect_no_offenses(<<~RUBY)
          build(:user)
        RUBY
      end
    end

    it 'flags the call with an explicit receiver' do
      expect_offense(<<~RUBY)
        FactoryBot.create :user
                   ^^^^^^ Prefer method call with parentheses
      RUBY
    end

    it 'ignores FactoryBot DSL methods without a first positional argument' do
      expect_no_offenses(<<~RUBY)
        create
        create foo: :bar
      RUBY
    end
  end

  context 'when EnforcedStyle is :omit_parentheses' do
    let(:enforced_style) { :omit_parentheses }

    context 'with create' do
      it 'flags the call to not use parentheses' do
        expect_offense(<<~RUBY)
          create(:user)
          ^^^^^^ Prefer method call without parentheses
        RUBY

        expect_correction(<<~RUBY)
          create :user
        RUBY
      end
    end

    context 'with nest call' do
      it 'inner call is ignored and not fixed' do
        expect_no_offenses(<<~RUBY)
          puts(1, create(:user))
        RUBY
      end
    end

    context 'with multiline method calls' do
      it 'removes parentheses around multiline call' do
        expect_offense(<<~RUBY)
          create(:user,
          ^^^^^^ Prefer method call without parentheses
            username: "PETER",
            peter: "USERNAME")
        RUBY

        expect_correction(<<~RUBY)
          create :user,
            username: "PETER",
            peter: "USERNAME"
        RUBY
      end
    end

    context 'with mixed tests' do
      it 'flags the call not to use parentheses' do
        expect_offense(<<~RUBY)
          build_list(:user, 10)
          ^^^^^^^^^^ Prefer method call without parentheses
          build_list("user", 10)
          ^^^^^^^^^^ Prefer method call without parentheses
          create_list(:user, 10)
          ^^^^^^^^^^^ Prefer method call without parentheses
          build_stubbed(:user)
          ^^^^^^^^^^^^^ Prefer method call without parentheses
          build_stubbed_list(:user, 10)
          ^^^^^^^^^^^^^^^^^^ Prefer method call without parentheses
          build(factory)
          ^^^^^ Prefer method call without parentheses
        RUBY

        expect_correction(<<~RUBY)
          build_list :user, 10
          build_list "user", 10
          create_list :user, 10
          build_stubbed :user
          build_stubbed_list :user, 10
          build factory
        RUBY
      end
    end

    context 'with build' do
      it 'flags the call to not use parentheses' do
        expect_offense(<<~RUBY)
          build(:user)
          ^^^^^ Prefer method call without parentheses
        RUBY

        expect_correction(<<~RUBY)
          build :user
        RUBY
      end
    end

    context 'with nested calling' do
      it 'flags the call to use parentheses' do
        expect_offense(<<~RUBY)
          build(:user, build(:yester))
          ^^^^^ Prefer method call without parentheses
        RUBY

        expect_correction(<<~RUBY)
          build :user, build(:yester)
        RUBY
      end
    end

    context 'with nested calling that does not require fixing' do
      it 'does not flag the nested call' do
        expect_no_offenses(<<~RUBY)
          build :user, build(:yester)
        RUBY
      end
    end

    context 'when is a part of a hash' do
      it 'does not flag the call' do
        expect_no_offenses(<<~RUBY)
          build :user, home: build(:address)
        RUBY
      end
    end

    context 'when is a part of an array' do
      it 'does not flag the call' do
        expect_no_offenses(<<~RUBY)
          users = [
            build(:user),
            build(:user)
          ]
        RUBY
      end
    end

    context 'with already valid usage of parentheses' do
      it 'does not flag as invalid - create' do
        expect_no_offenses(<<~RUBY)
          create :user
        RUBY
      end

      it 'does not flag as invalid - build' do
        expect_no_offenses(<<~RUBY)
          build :user
        RUBY
      end
    end

    it 'works in a bigger context' do
      expect_offense(<<~RUBY)
        RSpec.describe Context do
          let(:build) { create(:user, build(:user)) }
                        ^^^^^^ Prefer method call without parentheses

          it 'test in test' do
            user = create(:user, first: name, peter: miller)
                   ^^^^^^ Prefer method call without parentheses
          end

          let(:build) { create(:user, build(:user, create(:user, create(:first_name)))) }
                        ^^^^^^ Prefer method call without parentheses
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe Context do
          let(:build) { create :user, build(:user) }

          it 'test in test' do
            user = create :user, first: name, peter: miller
          end

          let(:build) { create :user, build(:user, create(:user, create(:first_name))) }
        end
      RUBY
    end

    context 'when create and first argument are on same line' do
      it 'register an offense' do
        expect_offense(<<~RUBY)
          create(:user,
          ^^^^^^ Prefer method call without parentheses
            name: 'foo'
          )
        RUBY

        expect_correction(<<~RUBY)
          create :user,
            name: 'foo'

        RUBY
      end
    end

    context 'when create and first argument are not on same line' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          create(
            :user
          )
        RUBY
      end
    end

    context 'when create and some argument are not on same line' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          create(
            :user,
            name: 'foo'
          )
        RUBY
      end
    end

    it 'flags the call with an explicit receiver' do
      expect_offense(<<~RUBY)
        FactoryBot.create(:user)
                   ^^^^^^ Prefer method call without parentheses
      RUBY
    end

    it 'ignores FactoryBot DSL methods without a first positional argument' do
      expect_no_offenses(<<~RUBY)
        create()
        create(foo: :bar)
      RUBY
    end
  end
end
