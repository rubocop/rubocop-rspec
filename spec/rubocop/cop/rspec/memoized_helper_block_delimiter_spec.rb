# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MemoizedHelperBlockDelimiter do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'when EnforcedStyle is :braces' do
    let(:enforced_style) do
      :braces
    end

    context 'with braces style is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          let(:foo) {
            'bar'
          }
        RUBY
      end
    end

    context 'with do_end style is used' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          let(:foo) do
                    ^^ Use braces style block delimiters.
            'bar'
          end
        RUBY

        expect_no_corrections
      end
    end

    context 'with do_end style is used with rescue' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          let(:foo) do
                    ^^ Use braces style block delimiters.
            'bar'
          rescue
            'baz'
          end
        RUBY

        expect_no_corrections
      end
    end
  end

  context 'when EnforcedStyle is :do_end' do
    let(:enforced_style) do
      :do_end
    end

    context 'when do_end style is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          let(:foo) do
            'bar'
          end
        RUBY
      end
    end

    context 'when braces style is used on `let`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          let(:foo) {
                    ^ Use do_end style block delimiters.
            'bar'
          }
        RUBY

        expect_correction(<<~RUBY)
          let(:foo) do
            'bar'
          end
        RUBY
      end
    end

    context 'when braces style is used on `subject`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          subject(:foo) {
                        ^ Use do_end style block delimiters.
            'bar'
          }
        RUBY

        expect_correction(<<~RUBY)
          subject(:foo) do
            'bar'
          end
        RUBY
      end
    end

    context 'when braces style is used in one-line style' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          let(:foo) { 'bar' }
                    ^^^^^^^^^ Use do_end style block delimiters.
        RUBY

        expect_correction(<<~RUBY)
          let(:foo) do
           'bar'#{' '}
          end
        RUBY
      end
    end

    context 'when braces style is used in without spaces' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          let(:foo){'bar'}
                   ^^^^^^^ Use do_end style block delimiters.
        RUBY

        expect_correction(<<~RUBY)
          let(:foo) do
          'bar'
          end
        RUBY
      end
    end
  end
end
