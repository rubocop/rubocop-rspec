# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MetadataStyle do
  context 'with `EnforcedStyle: symbol`' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'symbol' }
    end

    context 'with symbol metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', :a do
          end
        RUBY
      end
    end

    context 'with false metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', a: false do
          end
        RUBY
      end
    end

    context 'with string key metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', 'a' => true do
          end
        RUBY
      end
    end

    context 'with 1 boolean keyword arguments metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', a: true do
                                ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a do
          end
        RUBY
      end
    end

    context 'with 2 boolean keyword arguments metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', a: true, b: true do
                                         ^^^^^^^ Use symbol style for metadata.
                                ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, :b do
          end
        RUBY
      end
    end

    context 'with non-boolean and boolean keyword arguments metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', b: 1, a: true do
                                      ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, b: 1 do
          end
        RUBY
      end
    end

    context 'with boolean and non-boolean keyword arguments metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', a: true, b: 1 do
                                ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, b: 1 do
          end
        RUBY
      end
    end

    context 'with non-literal metadata and symbol metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', a, :b do
          end
        RUBY
      end
    end

    context 'with boolean keyword arguments metadata and symbol metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :b, a: true do
                                    ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :b, :a do
          end
        RUBY
      end
    end

    context 'with 1 boolean hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', { a: true } do
                                  ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, {  } do
          end
        RUBY
      end
    end

    context 'with 2 boolean hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', { a: true, b: true } do
                                           ^^^^^^^ Use symbol style for metadata.
                                  ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, :b, {  } do
          end
        RUBY
      end
    end

    context 'with boolean and non-boolean hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', { a: true, b: 1 } do
                                  ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, { b: 1 } do
          end
        RUBY
      end
    end

    context 'with non-boolean and boolean hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', { b: 1, a: true } do
                                        ^^^^^^^ Use symbol style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', :a, { b: 1 } do
          end
        RUBY
      end
    end

    context 'with non-symbol-key hash metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', a => true do
          end
        RUBY
      end
    end
  end

  context 'with `EnforcedStyle: hash`' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'hash' }
    end

    context 'with boolean keyword arguments metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', a: true do
          end
        RUBY
      end
    end

    context 'with boolean hash metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', { a: true } do
          end
        RUBY
      end
    end

    context 'with boolean hash metadata after 2 string arguments' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', 'Something else', { a: true } do
          end
        RUBY
      end
    end

    context 'with 1 symbol metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :a do
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', a: true do
          end
        RUBY
      end
    end

    context 'with 2 symbol metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :a, :b do
                                    ^^ Use hash style for metadata.
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', b: true, a: true do
          end
        RUBY
      end
    end

    context 'with 2 non-literal metadata' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', a, b do
          end
        RUBY
      end
    end

    context 'with symbol metadata after 2 string arguments' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', 'Something else', :a do
                                                  ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', 'Something else', a: true do
          end
        RUBY
      end
    end

    context 'with symbol metadata after non-literal metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', a, :b do
                                   ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', a, b: true do
          end
        RUBY
      end
    end

    context 'with symbol metadata with parentheses' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe('Something', :a) do
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe('Something', a: true) do
          end
        RUBY
      end
    end

    context 'with symbol metadata with another existing hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :a, b: 1 do
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', b: 1, a: true do
          end
        RUBY
      end
    end

    context 'with symbol metadata with another existing braces hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :a, { b: 1 } do
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', { b: 1, a: true } do
          end
        RUBY
      end
    end

    context 'with symbol metadata with another existing empty hash metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :a, {} do
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', { a: true } do
          end
        RUBY
      end
    end

    context 'with symbol metadata with another existing non-literal metadata' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          describe 'Something', :a, b do
                                ^^ Use hash style for metadata.
          end
        RUBY

        expect_no_corrections
      end
    end
  end
end
