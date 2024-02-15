# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExampleWording do
  it 'ignores non-example blocks' do
    expect_no_offenses('foo "should do something" do; end')
  end

  it 'finds description with `should` at the beginning' do
    expect_offense(<<~RUBY)
      it 'should do something' do
          ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does something' do
      end
    RUBY
  end

  it 'finds interpolated description with `should` at the beginning' do
    expect_offense(<<~'RUBY')
      it "should do #{:stuff}" do
          ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~'RUBY')
      it "does #{:stuff}" do
      end
    RUBY
  end

  it 'finds description with `Should` at the beginning' do
    expect_offense(<<~RUBY)
      it 'Should do something' do
          ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does something' do
      end
    RUBY
  end

  it "finds description with `shouldn't` at the beginning" do
    expect_offense(<<~RUBY)
      it "shouldn't do something" do
          ^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it "does not do something" do
      end
    RUBY
  end

  it "finds description with `SHOULDN'T` at the beginning" do
    expect_offense(<<~RUBY)
      it "SHOULDN'T do something" do
          ^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it "DOES NOT do something" do
      end
    RUBY
  end

  it 'flags a lone should' do
    expect_offense(<<~RUBY)
      it 'should' do
          ^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it '' do
      end
    RUBY
  end

  it 'flags a lone should not' do
    expect_offense(<<~RUBY)
      it 'should not' do
          ^^^^^^^^^^ Do not use should when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does not' do
      end
    RUBY
  end

  it 'finds description with `will` at the beginning' do
    expect_offense(<<~RUBY)
      it 'will do something' do
          ^^^^^^^^^^^^^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does something' do
      end
    RUBY
  end

  it 'finds interpolated description with `will` at the beginning' do
    expect_offense(<<~'RUBY')
      it "will do #{:stuff}" do
          ^^^^^^^^^^^^^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~'RUBY')
      it "does #{:stuff}" do
      end
    RUBY
  end

  it 'finds description with `Will` at the beginning' do
    expect_offense(<<~RUBY)
      it 'Will do something' do
          ^^^^^^^^^^^^^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does something' do
      end
    RUBY
  end

  it "finds description with `won't` at the beginning" do
    expect_offense(<<~RUBY)
      it "won't do something" do
          ^^^^^^^^^^^^^^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it "does not do something" do
      end
    RUBY
  end

  it "finds description with `WON'T` at the beginning" do
    expect_offense(<<~RUBY)
      it "WON'T do something" do
          ^^^^^^^^^^^^^^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it "DOES NOT do something" do
      end
    RUBY
  end

  it 'flags a lone will' do
    expect_offense(<<~RUBY)
      it 'will' do
          ^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it '' do
      end
    RUBY
  end

  it 'flags a lone will not' do
    expect_offense(<<~RUBY)
      it 'will not' do
          ^^^^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does not' do
      end
    RUBY
  end

  it "flags a lone won't" do
    expect_offense(<<~RUBY)
      it "won't" do
          ^^^^^ Do not use the future tense when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it "does not" do
      end
    RUBY
  end

  it 'finds leading its' do
    expect_offense(<<~RUBY)
      it "it does something" do
          ^^^^^^^^^^^^^^^^^ Do not repeat 'it' when describing your tests.
      end
    RUBY

    expect_correction(<<~RUBY)
      it "does something" do
      end
    RUBY
  end

  it 'finds leading it in interpolated description' do
    expect_offense(<<~'RUBY')
      it "it does #{action}" do
          ^^^^^^^^^^^^^^^^^ Do not repeat 'it' when describing your tests.
      end
    RUBY

    expect_correction(<<~'RUBY')
      it "does #{action}" do
      end
    RUBY
  end

  it "skips words beginning with 'it'" do
    expect_no_offenses(<<~RUBY)
      it 'itemizes items' do
      end
    RUBY
  end

  it 'skips descriptions without `should` at the beginning' do
    expect_no_offenses(<<~RUBY)
      it 'finds no should here' do
      end
    RUBY
  end

  it 'skips descriptions starting with words that begin with `should`' do
    expect_no_offenses(<<~RUBY)
      it 'shoulders the burden' do
      end
    RUBY
  end

  it 'skips interpolated description without literal `should` at the start' do
    expect_no_offenses(<<~'RUBY')
      it "#{should} not be here" do
      end
    RUBY
  end

  it 'flags \-separated multiline strings' do
    expect_offense(<<~'RUBY')
      it 'should do something ' \
          ^^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
          'and correctly fix' do
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'does something and correctly fix' do
      end
    RUBY
  end

  it 'flags \-separated multiline interpolated strings' do
    expect_offense(<<~'RUBY')
      it "should do something " \
          ^^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
          "with #{object}" do
      end
    RUBY

    expect_correction(<<~'RUBY')
      it "does something with #{object}" do
      end
    RUBY
  end

  it 'ignores heredocs' do
    expect_offense(<<~RUBY)
      it <<~DESC do
          ^^^^^ Do not use should when describing your tests.
        should not start with this word
      DESC
      end
    RUBY
  end

  it 'flags an unclear description' do
    expect_offense(<<~RUBY)
      it "works" do
          ^^^^^ Your example description is insufficient.
      end
    RUBY
  end

  it 'flags an unclear description despite extra spaces' do
    expect_offense(<<~RUBY)
      it "  works    " do
          ^^^^^^^^^^^ Your example description is insufficient.
      end
    RUBY
  end

  it 'flags an unclear description despite uppercase and lowercase strings' do
    expect_offense(<<~RUBY)
      it "WOrKs " do
          ^^^^^^ Your example description is insufficient.
      end
    RUBY
  end

  context 'when `DisallowedExamples: Workz`' do
    let(:cop_config) { { 'DisallowedExamples' => ['Workz'] } }

    it 'finds a valid sentence across two lines' do
      expect_no_offenses(<<~'RUBY')
        it "workz " \
          "totally fine " do
        end
      RUBY
    end

    it 'finds an invalid example across two lines' do
      expect_offense(<<~'RUBY')
        it "workz" \
            ^^^^^^^^ Your example description is insufficient.
          " " do
        end
      RUBY
    end

    it 'flags an unclear description' do
      expect_offense(<<~RUBY)
        it "workz" do
            ^^^^^ Your example description is insufficient.
        end
      RUBY
    end

    it 'flags an unclear description despite uppercase and lowercase strings' do
      expect_offense(<<~RUBY)
        it "WOrKz " do
            ^^^^^^ Your example description is insufficient.
        end
      RUBY
    end
  end

  context "when message includes `'` in `'...'`" do
    it 'corrects message with `String#inspect`' do
      expect_offense(<<~'RUBY')
        it 'should return foo\'s bar' do
            ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<~RUBY)
        it "returns foo's bar" do
        end
      RUBY
    end
  end

  context 'when message includes `"` in `"..."`' do
    it 'corrects message with `String#inspect`' do
      expect_offense(<<~'RUBY')
        it "should return \"foo\"" do
            ^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<~'RUBY')
        it "returns \"foo\"" do
        end
      RUBY
    end
  end

  context 'when message includes `!` in `%!...!`' do
    it 'corrects message with `String#inspect`' do
      expect_offense(<<~'RUBY')
        it %!should return foo\!! do
             ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<~RUBY)
        it "returns foo!" do
        end
      RUBY
    end
  end

  context 'when message includes `)` in `%q(...)`' do
    it 'corrects message with `String#inspect`' do
      expect_offense(<<~RUBY)
        it %q(should return foo (bar)) do
              ^^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<~RUBY)
        it "returns foo (bar)" do
        end
      RUBY
    end
  end

  context 'when message includes `"` in `%q(...)`' do
    it 'corrects message with direct substring replacement' do
      expect_offense(<<~RUBY)
        it %q(should return "foo") do
              ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<~RUBY)
        it %q(returns "foo") do
        end
      RUBY
    end
  end

  context 'when message includes `"` and `)` in `%q(...)`' do
    it 'corrects message with `String#inspect`' do
      expect_offense(<<~RUBY)
        it %q(should return "foo (bar)") do
              ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<~'RUBY')
        it "returns \"foo (bar)\"" do
        end
      RUBY
    end
  end
end
