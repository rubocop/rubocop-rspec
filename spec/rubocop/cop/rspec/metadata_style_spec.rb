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

    context 'with a block-pass' do
      it 'registers offense for boolean keyword arguments metadata' do
        expect_offense(<<~RUBY)
          it 'Something', a: true, &blk
                          ^^^^^^^ Use symbol style for metadata.
          it('Something', :a => true, &blk)
                          ^^^^^^^^^^ Use symbol style for metadata.
        RUBY

        expect_correction(<<~RUBY)
          it 'Something', :a, &blk
          it('Something', :a, &blk)
        RUBY
      end

      it 'registers no offense for symbol metadata' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', :a, &blk
          describe 'Something', &blk
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

    context 'with a block-pass' do
      it 'registers offense for symbol metadata without parentheses' do
        expect_offense(<<~RUBY)
          describe 'Something', :a, &blk
                                ^^ Use hash style for metadata.
        RUBY

        expect_correction(<<~RUBY)
          describe 'Something', a: true, &blk
        RUBY
      end

      it 'registers offense for symbol metadata with parentheses' do
        expect_offense(<<~RUBY)
          it('Something', :a, &blk)
                          ^^ Use hash style for metadata.
        RUBY

        expect_correction(<<~RUBY)
          it('Something', a: true, &blk)
        RUBY
      end

      it 'registers offense for 2 symbol metadata' do
        expect_offense(<<~RUBY)
          it 'Something', :a, :b, &blk
                              ^^ Use hash style for metadata.
                          ^^ Use hash style for metadata.
        RUBY

        expect_correction(<<~RUBY)
          it 'Something', b: true, a: true, &blk
        RUBY
      end

      it 'registers offense for symbol metadata with an existing hash' do
        expect_offense(<<~RUBY)
          it 'Something', :a, b: true, &blk
                          ^^ Use hash style for metadata.
        RUBY

        expect_correction(<<~RUBY)
          it 'Something', b: true, a: true, &blk
        RUBY
      end

      it 'registers offense for symbol metadata with an empty hash' do
        expect_offense(<<~RUBY)
          it 'Something', :a, {}, &blk
                          ^^ Use hash style for metadata.
        RUBY

        expect_correction(<<~RUBY)
          it 'Something', { a: true }, &blk
        RUBY
      end

      it 'does not autocorrect ambiguous trailing metadata' do
        expect_offense(<<~RUBY)
          it 'Something', :a, b, &blk
                          ^^ Use hash style for metadata.
        RUBY

        expect_no_corrections
      end

      it 'registers no offense for boolean keyword arguments metadata' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', a: true, &blk
        RUBY
      end

      it 'does not treat the block-pass as metadata' do
        expect_no_offenses(<<~RUBY)
          describe 'Something', &blk
        RUBY
      end
    end
  end
end
