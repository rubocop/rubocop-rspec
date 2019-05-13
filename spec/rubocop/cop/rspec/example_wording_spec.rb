# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExampleWording, :config do
  subject(:cop) { described_class.new(config) }

  context 'with configuration' do
    let(:cop_config) do
      {
        'CustomTransform' => { 'have' => 'has' },
        'IgnoredWords'    => %w[only really]
      }
    end

    it 'ignores non-example blocks' do
      expect_no_offenses('foo "should do something" do; end')
    end

    it 'finds description with `should` at the beginning' do
      expect_offense(<<-RUBY)
        it 'should do something' do
            ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something' do
        end
      RUBY
    end

    it 'finds description with `Should` at the beginning' do
      expect_offense(<<-RUBY)
        it 'Should do something' do
            ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something' do
        end
      RUBY
    end

    it 'finds description with `shouldn\'t` at the beginning' do
      expect_offense(<<-RUBY)
        it "shouldn't do something" do
            ^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it "does not do something" do
        end
      RUBY
    end

    it 'finds description with `SHOULDN\'T` at the beginning' do
      expect_offense(<<-RUBY)
        it "SHOULDN'T do something" do
            ^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it "DOES NOT do something" do
        end
      RUBY
    end

    it 'flags a lone should' do
      expect_offense(<<-RUBY)
        it 'should' do
            ^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it '' do
        end
      RUBY
    end

    it 'flags a lone should not' do
      expect_offense(<<-RUBY)
        it 'should not' do
            ^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does not' do
        end
      RUBY
    end

    it 'finds leading its' do
      expect_offense(<<-RUBY)
        it "it does something" do
            ^^^^^^^^^^^^^^^^^ Do not repeat 'it' when describing your tests.
        end
      RUBY

      expect_correction(<<-RUBY)
        it "does something" do
        end
      RUBY
    end

    it "skips words beginning with 'it'" do
      expect_no_offenses(<<-RUBY)
        it 'itemizes items' do
        end
      RUBY
    end

    it 'skips descriptions without `should` at the beginning' do
      expect_no_offenses(<<-RUBY)
        it 'finds no should here' do
        end
      RUBY
    end

    it 'skips descriptions starting with words that begin with `should`' do
      expect_no_offenses(<<-RUBY)
        it 'shoulders the burden' do
        end
      RUBY
    end
  end

  context 'when configuration is empty' do
    include_examples 'autocorrect',
                     'it "should have trait" do end',
                     'it "haves trait" do end'

    include_examples 'autocorrect',
                     'it "should only fail" do end',
                     'it "onlies fail" do end'
  end
end
