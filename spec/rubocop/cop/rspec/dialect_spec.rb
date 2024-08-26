# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Dialect do
  context 'with preferred methods' do
    context 'when `describe` is preferred to `context`' do
      let(:cop_config) do
        {
          'PreferredMethods' => {
            'context' => 'describe'
          }
        }
      end

      it 'allows describe blocks' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe 'context' do
            describe 'display name presence' do
            end
          end
        RUBY
      end

      it 'registers an offense for context blocks' do
        expect_offense(<<~RUBY)
          RSpec.describe 'context' do
            context 'display name presence' do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `describe` over `context`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          RSpec.describe 'context' do
            describe 'display name presence' do
            end
          end
        RUBY
      end
    end

    context 'when `describe` is preferred to `feature`' do
      let(:cop_config) do
        {
          'PreferredMethods' => {
            'feature' => 'describe'
          }
        }
      end

      it 'allows describe blocks' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe 'context' do
            describe 'display name presence' do
            end
          end
        RUBY
      end

      it 'registers an offense for feature blocks' do
        expect_offense(<<~RUBY)
          RSpec.describe 'context' do
            feature 'display name presence' do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `describe` over `feature`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          RSpec.describe 'context' do
            describe 'display name presence' do
            end
          end
        RUBY
      end
    end

    context 'when `let` is preferred to `given`' do
      let(:cop_config) do
        {
          'PreferredMethods' => {
            'given' => 'let'
          }
        }
      end

      it 'allows let blocks' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe 'context' do
            let do
            end
          end
        RUBY
      end

      it 'registers an offense for given blocks' do
        expect_offense(<<~RUBY)
          RSpec.describe 'context' do
            given do
            ^^^^^ Prefer `let` over `given`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          RSpec.describe 'context' do
            let do
            end
          end
        RUBY
      end
    end

    context 'when `let!` is preferred to `given!`' do
      let(:cop_config) do
        {
          'PreferredMethods' => {
            'given!' => 'let!'
          }
        }
      end

      it 'allows let! blocks' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe 'context' do
            let! do
            end
          end
        RUBY
      end

      it 'registers an offense for given! blocks' do
        expect_offense(<<~RUBY)
          RSpec.describe 'context' do
            given! do
            ^^^^^^ Prefer `let!` over `given!`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          RSpec.describe 'context' do
            let! do
            end
          end
        RUBY
      end
    end

    context 'when `before` is preferred to `background`' do
      let(:cop_config) do
        {
          'PreferredMethods' => {
            'background' => 'before'
          }
        }
      end

      it 'allows before blocks' do
        expect_no_offenses(<<~RUBY)
          RSpec.describe 'context' do
            before do
            end
          end
        RUBY
      end

      it 'registers an offense for background blocks' do
        expect_offense(<<~RUBY)
          RSpec.describe 'context' do
            background do
            ^^^^^^^^^^ Prefer `before` over `background`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          RSpec.describe 'context' do
            before do
            end
          end
        RUBY
      end
    end
  end

  context 'without preferred methods' do
    let(:cop_config) do
      {
        'PreferredMethods' => {}
      }
    end

    it 'allows all methods blocks' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe 'context' do
          context 'is important' do
            specify 'for someone to work' do
              everyone.should have_some_leeway
            end
          end
        end
      RUBY
    end
  end
end
