# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::VariableName do
  context 'when configured for `snake_case`' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    context 'when `let` with symbol names' do
      it 'registers an offense for camelCase' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:userName) { 'Adam' }
                ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'registers an offense for PascalCase' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:UserName) { 'Adam' }
                ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'registers offense with multiple lets' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:userName) { 'Adam' }
                ^^^^^^^^^ Use snake_case for variable names.
            let(:user_email) { 'adam@example.com' }
            let(:userAge) { 20 }
                ^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'does not register an offense for snake_case' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            let(:user_name) { 'Adam' }
          end
        RUBY
      end

      it 'does not register offense for interpolated symbol' do
        expect_no_offenses(<<~'RUBY')
          RSpec.describe Foo do
            let(:"user#{name}") { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `let` with string names' do
      it 'registers an offense for camelCase' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let('userName') { 'Adam' }
                ^^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'registers an offense for kebab-case' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let('user-name') { 'Adam' }
                ^^^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'does not register an offense for snake_case' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            let('user_name') { 'Adam' }
          end
        RUBY
      end

      it 'does not register offense for interpolated string' do
        expect_no_offenses(<<~'RUBY')
          RSpec.describe Foo do
            let("user#{name}") { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `let` with proc' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:userName, &create_user)
                ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end
    end

    context 'when `let!`' do
      it 'registers an offense for camelCase' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let!(:userName) { 'Adam' }
                 ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'does not register offense for snake_case' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            let!(:user_name) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `subject`' do
      it 'registers an offense for camelCase' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            subject(:userName) { 'Adam' }
                    ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'does not register offense for snake_case' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            subject(:user_name) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `subject!`' do
      it 'registers an offense for camelCase' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            subject!(:userName) { 'Adam' }
                     ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'does not register offense for snake_case' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            subject!(:user_name) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `let` inside spec group' do
      it 'registers an offense when describe' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:userName) { 'Adam' }
                ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end

      it 'registers an offense when shared_examples' do
        expect_offense(<<~RUBY)
          RSpec.shared_examples 'foo example' do
            let(:userName) { 'Adam' }
                ^^^^^^^^^ Use snake_case for variable names.
          end
        RUBY
      end
    end

    context 'when `let` not inside spec group' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          let(:userName) { 'Adam' }
        RUBY
      end
    end
  end

  context 'when configured for `camelCase`' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    context 'when `let`' do
      it 'registers an offense for snake_case' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:user_name) { 'Adam' }
                ^^^^^^^^^^ Use camelCase for variable names.
          end
        RUBY
      end

      it 'does not register offense for camelCase' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            let(:userName) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `let!`' do
      it 'registers an offense for snake_case' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let!(:user_name) { 'Adam' }
                 ^^^^^^^^^^ Use camelCase for variable names.
          end
        RUBY
      end

      it 'does not register offense for camelCase' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            let!(:userName) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `subject`' do
      it 'registers an offense for snake_case' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            subject(:user_name) { 'Adam' }
                    ^^^^^^^^^^ Use camelCase for variable names.
          end
        RUBY
      end

      it 'does not register offense for camelCase' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            subject(:userName) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `subject!`' do
      it 'registers an offense for snake_case' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            subject!(:user_name) { 'Adam' }
                     ^^^^^^^^^^ Use camelCase for variable names.
          end
        RUBY
      end

      it 'does not register offense for camelCase' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe Foo do
            subject!(:userName) { 'Adam' }
          end
        RUBY
      end
    end

    context 'when `let` inside spec group' do
      it 'registers an offense when describe' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            let(:user_name) { 'Adam' }
                ^^^^^^^^^^ Use camelCase for variable names.
          end
        RUBY
      end

      it 'registers an offense when shared_examples' do
        expect_offense(<<~RUBY)
          RSpec.shared_examples 'foo example' do
            let(:user_name) { 'Adam' }
                ^^^^^^^^^^ Use camelCase for variable names.
          end
        RUBY
      end
    end

    context 'when `let` not inside spec group' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          let(:user_name) { 'Adam' }
        RUBY
      end
    end
  end

  context 'when configured to ignore certain patterns (deprecated key)' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'snake_case',
        'IgnoredPatterns' => ['^userFood$', '^userPet$'] }
    end

    it 'registers an offense when not matching any ignored patterns' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          let(:userName) { 'Adam' }
              ^^^^^^^^^ Use snake_case for variable names.
        end
      RUBY
    end

    it 'does not register an offense when matching any ignored pattern' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          let(:userFood) { 'Adam' }
        end
      RUBY
    end
  end

  context 'when configured to allow certain patterns' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'snake_case',
        'AllowedPatterns' => ['^userFood$', '^userPet$'] }
    end

    it 'registers an offense when not matching any allowed patterns' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          let(:userName) { 'Adam' }
              ^^^^^^^^^ Use snake_case for variable names.
        end
      RUBY
    end

    it 'does not register an offense when matching any allowed pattern' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          let(:userFood) { 'Adam' }
        end
      RUBY
    end
  end
end
