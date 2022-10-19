# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::NoExpectationExample do
  context 'with no expectation example with it' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          it { bar }
          ^^^^^^^^^^ No expectation found in this example.

          it { expect(baz).to be_truthy }
        end
      RUBY
    end
  end

  context 'with no expectation example with specify' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        specify { bar }
        ^^^^^^^^^^^^^^^ No expectation found in this example.
      RUBY
    end
  end

  context 'with expectation example with should' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        it { should be_truthy }
      RUBY
    end
  end

  context 'with multi no expectation examples' do
    it 'registers offenses' do
      expect_offense(<<~RUBY)
        it { bar }
        ^^^^^^^^^^ No expectation found in this example.
        it { baz }
        ^^^^^^^^^^ No expectation found in this example.
      RUBY
    end
  end

  context 'with custom expectation example' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        it { custom_expect(bar) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^ No expectation found in this example.
      RUBY
    end
  end

  context 'with configured custom expectation example' do
    before do
      other_cops.dig('RSpec', 'Language', 'Expectations').push('custom_expect')
    end

    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        it { custom_expect(bar) }
      RUBY
    end
  end

  context 'with no expectation custom example' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        custom_it { foo }
      RUBY
    end
  end

  context 'with no expectation configured custom example' do
    before do
      other_cops.dig(
        'RSpec',
        'Language',
        'Examples',
        'Regular'
      ).push('custom_it')
    end

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        custom_it { foo }
        ^^^^^^^^^^^^^^^^^ No expectation found in this example.
      RUBY
    end
  end

  context 'with block-less example in block' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          it 'not implemented'
        end
      RUBY
    end
  end

  context 'with no expectation pending example' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        pending { bar }
      RUBY
    end
  end

  context 'with no expectation skipped example' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        skip { bar }
      RUBY
    end
  end

  context 'with no expectation pending example when using `pending` ' \
          'inside an example' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        it "is implemented but waiting" do
          pending "something else getting finished"
        end
      RUBY
    end
  end

  context 'with no expectation skipped example when using `skip` ' \
          'inside an example' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        it "is skipped" do
          skip
        end
      RUBY
    end
  end

  it 'registers no offense for skipped/pending with metadata' do
    expect_no_offenses(<<~RUBY)
      it 'is skipped', :skip do
        foo
      end
      it 'is skipped', skip: true do
        foo
      end
      it 'is pending', :pending do
        foo
      end
      it 'is pending', pending: true do
        foo
      end
    RUBY
  end

  context 'when `AllowedPatterns: [^expect_]`' do
    let(:cop_config) { { 'AllowedPatterns' => ['^expect_'] } }

    context 'when only allowed pattern methods are used' do
      it 'registers no offenses' do
        expect_no_offenses(<<~RUBY)
          it { expect_something }
        RUBY
      end
    end

    context 'when allowed pattern methods and other method are used' do
      it 'registers no offenses' do
        expect_no_offenses(<<~RUBY)
          it do
            do_something
            expect_something
            do_something
          end
        RUBY
      end
    end

    context 'when nested allowed pattern methods and other method are used' do
      it 'registers no offenses' do
        expect_no_offenses(<<~RUBY)
          it do
            do_something
            some_patterns.each do
              expect_something
            end
            do_something
          end
        RUBY
      end
    end

    context 'when only not allowed pattern methods are used' do
      it 'does something' do
        expect_offense(<<~RUBY)
          it { not_expect_something }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ No expectation found in this example.
        RUBY
      end
    end
  end

  context 'when Ruby 2.7', :ruby27 do
    context 'with no expectation example with it' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          RSpec.describe Foo do
            it { _1 }
            ^^^^^^^^^ No expectation found in this example.

            it { expect(baz).to be_truthy }
          end
        RUBY
      end
    end
  end
end
