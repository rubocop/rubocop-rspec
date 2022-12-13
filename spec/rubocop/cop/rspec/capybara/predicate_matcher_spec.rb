# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::PredicateMatcher do
  let(:cop_config) do
    {
      'EnforcedStyle' => enforced_style,
      'Strict' => strict,
      'AllowedExplicitMatchers' => allowed_explicit_matchers
    }
  end
  let(:allowed_explicit_matchers) { [] }

  context 'when `EnforcedStyle: inflected`' do
    let(:enforced_style) { 'inflected' }

    shared_examples 'inflected common' do
      it 'registers an offense when using predicate method' do
        expect_offense(<<~RUBY)
          expect(foo.matches_css?(bar: 'baz')).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `match_css` matcher over `matches_css?`.
          expect(foo.matches_selector?(bar: 'baz')).to be_falsey
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `match_selector` matcher over `matches_selector?`.
          expect(foo.matches_style?(bar: 'baz')).not_to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `match_style` matcher over `matches_style?`.
          expect(foo.matches_xpath?(bar: 'baz', foo: 'bar')).not_to be_falsey
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `match_xpath` matcher over `matches_xpath?`.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to match_css(bar: 'baz')
          expect(foo).not_to match_selector(bar: 'baz')
          expect(foo).not_to match_style(bar: 'baz')
          expect(foo).to match_xpath(bar: 'baz', foo: 'bar')
        RUBY
      end

      it 'does not register an offense when using non-predicate method' do
        expect_no_offenses(<<~RUBY)
          expect(foo).to match_css(bar: 'baz')
          expect(foo).not_to match_selector(bar: 'baz')
          expect(foo).not_to match_style(bar: 'baz')
          expect(foo).to match_xpath(bar: 'baz', foo: 'bar')
        RUBY
      end
    end

    context 'when `Strict: true`' do
      let(:strict) { true }

      include_examples 'inflected common'

      it 'does not register an offense when strict checking boolean matcher' do
        expect_no_offenses(<<~RUBY)
          expect(foo.matches_css?(bar: 'baz')).to eq(true)
          expect(foo.matches_selector?(bar: 'baz')).not_to be(false)
        RUBY
      end
    end

    context 'when `Strict: false`' do
      let(:strict) { false }

      include_examples 'inflected common'

      it 'registers an offense when predicate method in actual' do
        expect_offense(<<~RUBY)
          expect(foo.matches_css?(bar: 'baz')).to eq(true)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `match_css` matcher over `matches_css?`.
          expect(foo.matches_style?(bar: 'baz')).not_to be(false)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `match_style` matcher over `matches_style?`.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to match_css(bar: 'baz')
          expect(foo).to match_style(bar: 'baz')
        RUBY
      end
    end
  end

  context 'when `EnforcedStyle: explicit`' do
    let(:enforced_style) { 'explicit' }

    shared_examples 'explicit' do |matcher_true, matcher_false|
      it 'registers an offense for a predicate mather' do
        expect_offense(<<~RUBY)
          expect(foo).to match_css(bar: 'baz')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `matches_css?` over `match_css` matcher.
          expect(foo).not_to match_selector(bar: 'baz')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `matches_selector?` over `match_selector` matcher.
          expect(foo).not_to match_style(bar: 'baz')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `matches_style?` over `match_style` matcher.
          expect(foo).to match_xpath(bar: 'baz', foo: 'bar')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `matches_xpath?` over `match_xpath` matcher.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo.matches_css?(bar: 'baz')).to #{matcher_true}
          expect(foo.matches_selector?(bar: 'baz')).to #{matcher_false}
          expect(foo.matches_style?(bar: 'baz')).to #{matcher_false}
          expect(foo.matches_xpath?(bar: 'baz', foo: 'bar')).to #{matcher_true}
        RUBY
      end

      context 'when `AllowedExplicitMatchers: match_xpath`' do
        let(:allowed_explicit_matchers) { ['match_xpath'] }

        it 'does not register an offense when ' \
           'using custom allowed explicit matchers' do
          expect_no_offenses(<<~RUBY)
            expect(foo).to match_xpath(bar: 'baz', foo: 'bar')
          RUBY
        end
      end

      it 'does not register an offense when non-predicate matcher' do
        expect_no_offenses(<<~RUBY)
          expect(foo.matches_css?(bar: 'baz')).to #{matcher_true}
          expect(foo.matches_selector?(bar: 'baz')).not_to #{matcher_true}
          expect(foo.matches_style?(bar: 'baz')).to {matcher_false}
          expect(foo.matches_xpath?(bar: 'baz', foo: 'bar')).not_to {matcher_false}
        RUBY
      end
    end

    context 'when `Strict: true`' do
      let(:strict) { true }

      include_examples 'explicit', 'be(true)', 'be(false)'
    end

    context 'when `Strict: false`' do
      let(:strict) { false }

      include_examples 'explicit', 'be_truthy', 'be_falsey'
    end
  end
end
