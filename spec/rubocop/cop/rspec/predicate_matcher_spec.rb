# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::PredicateMatcher do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style,
      'Strict' => strict,
      'AllowedExplicitMatchers' => allowed_explicit_matchers }
  end
  let(:allowed_explicit_matchers) { [] }

  context 'when enforced style is `inflected`' do
    let(:enforced_style) { 'inflected' }

    shared_examples 'inflected common' do
      it 'registers an offense for a predicate method in actual' do
        expect_offense(<<~RUBY)
          expect(foo.empty?).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).to be_truthy, 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).not_to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).to_not be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).to be_falsey
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).not_to be_falsey
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).not_to a_truthy_value
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to be_empty
          expect(foo).to be_empty, 'fail'
          expect(foo).not_to be_empty
          expect(foo).not_to be_empty
          expect(foo).not_to be_empty
          expect(foo).to be_empty
          expect(foo).not_to be_empty
        RUBY
      end

      it 'registers an offense for a predicate method with built-in equiv' do
        expect_offense(<<~RUBY)
          expect(foo.exist?).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `exist` matcher over `exist?`.
          expect(foo.exist?).to be_truthy, 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `exist` matcher over `exist?`.
          expect(foo.exists?).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `exist` matcher over `exists?`.
          expect(foo.has_something?).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `have_something` matcher over `has_something?`.
          expect(foo.has_something?).not_to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `have_something` matcher over `has_something?`.
          expect(foo.include?(something)).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `include` matcher over `include?`.
          expect(foo.respond_to?(:bar)).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `respond_to` matcher over `respond_to?`.
          expect(foo.something?()).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to exist
          expect(foo).to exist, 'fail'
          expect(foo).to exist
          expect(foo).to have_something
          expect(foo).not_to have_something
          expect(foo).to include(something)
          expect(foo).to respond_to(:bar)
          expect(foo).to be_something()
        RUBY
      end

      it 'accepts respond_to? with a second argument' do
        expect_no_offenses(<<~RUBY)
          expect(foo.respond_to?(:bar, true)).to be_truthy
        RUBY
      end

      it 'registers an offense for a predicate method with argument' do
        expect_offense(<<~RUBY)
          expect(foo.something?('foo')).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
          expect(foo.something?('foo')).to be_truthy, 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
          expect(foo.something?('foo', 'bar')).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
          expect(foo.something? 1, 2).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
          expect(foo.has_key?('foo')).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `have_key` matcher over `has_key?`.
          expect(foo.is_a?(Array)).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_a` matcher over `is_a?`.
          expect(foo.instance_of?(Array)).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_an_instance_of` matcher over `instance_of?`.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to be_something('foo')
          expect(foo).to be_something('foo'), 'fail'
          expect(foo).to be_something('foo', 'bar')
          expect(foo).to be_something 1, 2
          expect(foo).to have_key('foo')
          expect(foo).to be_a(Array)
          expect(foo).to be_an_instance_of(Array)
        RUBY
      end

      it 'registers an offense for a predicate method with heredoc' do
        expect_offense(<<~RUBY)
          expect(foo.something?(<<~TEXT)).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
            bar
          TEXT
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to be_something(<<~TEXT)
            bar
          TEXT
        RUBY
      end

      it 'registers an offense for a predicate method with a block' do
        expect_offense(<<~RUBY)
          expect(foo.all?(&:present?)).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
          expect(foo.all?(&:present?)).to be_truthy, 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
          expect(foo.all? { |x| x.present? }).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
          expect(foo.all?(n) { |x| x.present? }).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
          expect(foo.all? { present }).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
          expect(foo.something?(x) { |y| y.present? }).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_something` matcher over `something?`.
          expect(foo.all? { }).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
          expect(foo.all? do; end).to be_truthy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.

          expect(foo.all? do |x|
          ^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_all` matcher over `all?`.
            x + 1
            x >= 2
          end).to be_truthy
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to be_all(&:present?)
          expect(foo).to be_all(&:present?), 'fail'
          expect(foo).to be_all { |x| x.present? }
          expect(foo).to be_all(n) { |x| x.present? }
          expect(foo).to be_all { present }
          expect(foo).to be_something(x) { |y| y.present? }
          expect(foo).to be_all { }
          expect(foo).to be_all do; end

          expect(foo).to be_all do |x|
            x + 1
            x >= 2
          end
        RUBY
      end

      it 'accepts a predicate method that is not checked true/false' do
        expect_no_offenses(<<~RUBY)
          expect(foo.something?).to eq "something"
          expect(foo.something?).to eq "something", "fail"
          expect(foo.has_something?).to eq "something"
        RUBY
      end

      it 'accepts non-predicate method' do
        expect_no_offenses(<<~RUBY)
          expect(foo.something).to be(true)
          expect(foo.something).to be(true), 'fail'
          expect(foo.has_something).to be(true)
        RUBY
      end
    end

    context 'when strict is true' do
      let(:strict) { true }

      include_examples 'inflected common'

      it 'accepts strict checking boolean matcher' do
        expect_no_offenses(<<~RUBY)
          expect(foo.empty?).to eq(true)
          expect(foo.empty?).to eq(true), 'fail'
          expect(foo.empty?).to be(true)
          expect(foo.empty?).to be(false)
          expect(foo.empty?).not_to be true
          expect(foo.empty?).not_to be false
        RUBY
      end
    end

    context 'when strict is false' do
      let(:strict) { false }

      include_examples 'inflected common'

      it 'registers an offense for a predicate method in actual' do
        expect_offense(<<~RUBY)
          expect(foo.empty?).to eq(true)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).to eq(true), 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).not_to be(true)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).to be(true)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).to be(false)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).not_to be true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
          expect(foo.empty?).not_to be false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `be_empty` matcher over `empty?`.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo).to be_empty
          expect(foo).to be_empty, 'fail'
          expect(foo).not_to be_empty
          expect(foo).to be_empty
          expect(foo).not_to be_empty
          expect(foo).not_to be_empty
          expect(foo).to be_empty
        RUBY
      end
    end
  end

  context 'when enforced style is `explicit`' do
    let(:enforced_style) { 'explicit' }

    shared_examples 'explicit' do |matcher_true, matcher_false|
      it 'registers an offense for a predicate mather' do
        expect_offense(<<~RUBY)
          expect(foo).to be_empty
          ^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `empty?` over `be_empty` matcher.
          expect(foo).to be_empty, 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `empty?` over `be_empty` matcher.
          expect(foo).not_to be_empty
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `empty?` over `be_empty` matcher.
          expect(foo).to have_something
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `has_something?` over `have_something` matcher.
        RUBY
      end

      it 'registers an offense for a predicate mather with argument' do
        expect_offense(<<~RUBY)
          expect(foo).to be_something(1, 2)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
          expect(foo).to have_key(1)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `has_key?` over `have_key` matcher.
        RUBY
      end

      it 'registers an offense for a predicate matcher with a block' do
        expect_offense(<<~RUBY)
          expect(foo).to be_all(&:present?)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_all { |x| x.present? }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_all { present }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_something(x) { |y| y.present? }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
        RUBY
      end

      it 'accepts built in matchers' do
        expect_no_offenses(<<~RUBY)
          expect(foo).to be_truthy
          expect(foo).to be_truthy, 'fail'
          expect(foo).to be_falsey
          expect(foo).to be_falsy
          expect(foo).to have_attributes(name: 'foo')
          expect(foo).to have_received(:foo)
          expect(foo).to be_between(1, 10)
          expect(foo).to be_within(0.1).of(10.0)
          expect(foo).to exist
        RUBY
      end

      context 'when custom matchers are allowed' do
        let(:allowed_explicit_matchers) { ['have_http_status'] }

        it 'accepts custom allowed explicit matchers' do
          expect_no_offenses(<<~RUBY)
            expect(foo).to have_http_status(:ok)
          RUBY
        end
      end

      it 'accepts non-predicate matcher' do
        expect_no_offenses(<<~RUBY)
          expect(foo).to be(true)
          expect(foo).to be(true), 'fail'
        RUBY
      end

      it 'registers an offense for a predicate method with built-in equiv' do
        expect_offense(<<~RUBY)
          expect(foo).to be_something
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
          expect(foo).to be_something, 'fail'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
          expect(foo).not_to be_something
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
          expect(foo).to have_something
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `has_something?` over `have_something` matcher.
          expect(foo).to be_a(Array)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `is_a?` over `be_a` matcher.
          expect(foo).to be_instance_of(Array)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `instance_of?` over `be_instance_of` matcher.
          expect(foo).to include('bar')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `include?` over `include` matcher.
          expect(foo).to respond_to(:method)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `respond_to?` over `respond_to` matcher.
          expect(foo).to be_something()
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo.something?).to #{matcher_true}
          expect(foo.something?).to #{matcher_true}, 'fail'
          expect(foo.something?).to #{matcher_false}
          expect(foo.has_something?).to #{matcher_true}
          expect(foo.is_a?(Array)).to #{matcher_true}
          expect(foo.instance_of?(Array)).to #{matcher_true}
          expect(foo.include?('bar')).to #{matcher_true}
          expect(foo.respond_to?(:method)).to #{matcher_true}
          expect(foo.something?()).to #{matcher_true}
        RUBY
      end

      it 'registers an offense for a predicate method with argument' do
        expect_offense(<<~RUBY)
          expect(foo).to be_something(1)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
          expect(foo).to be_something(1, 2)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
          expect(foo).to be_something 1, 2
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
        RUBY

        expect_correction(<<~RUBY)
          expect(foo.something?(1)).to #{matcher_true}
          expect(foo.something?(1, 2)).to #{matcher_true}
          expect(foo.something? 1, 2).to #{matcher_true}
        RUBY
      end

      it 'registers an offense for a predicate method with heredoc' do
        expect_offense(<<~RUBY)
          expect(foo).to include(<<~TEXT)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `include?` over `include` matcher.
            bar
          TEXT
        RUBY

        expect_correction(<<~RUBY)
          expect(foo.include?(<<~TEXT)).to #{matcher_true}
            bar
          TEXT
        RUBY
      end

      it 'registers an offense for a predicate method with ' \
         'heredoc and multiline expect' do
        expect_offense(<<~RUBY)
          expect(foo)
          ^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
            .to be_something(<<~TEXT)
              bar
            TEXT

          expect(foo)
          ^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
            .to be_something(bar, <<~TEXT, 'baz')
              bar
            TEXT
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for a predicate method with ' \
         'heredoc include #{} and multiline expect' do
        expect_offense(<<~'RUBY')
          expect(foo)
          ^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
            .to be_something(<<~TEXT)
              #{bar}
            TEXT

          expect(foo)
          ^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
            .to be_something(bar, <<~TEXT, 'baz')
              #{bar}
            TEXT
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for a predicate method with ' \
         'heredoc surrounded by back ticks and multiline expect' do
        expect_offense(<<~RUBY)
          expect(foo)
          ^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
            .to be_something(<<~`COMMAND`)
              pwd
            COMMAND

          expect(foo)
          ^^^^^^^^^^^ Prefer using `something?` over `be_something` matcher.
            .to be_something(bar, <<~COMMAND, 'baz')
              pwd
            COMMAND
        RUBY

        expect_no_corrections
      end

      it 'does not register an offense for a `include` ' \
         'with no argument' do
        expect_no_offenses(<<~RUBY)
          expect(foo).to include
          expect(foo).to include, 'fail'
        RUBY
      end

      it 'does not register an offense for a `include` ' \
         'with multiple arguments' do
        expect_no_offenses(<<~RUBY)
          expect(foo).to include(foo, bar)
        RUBY
      end

      it 'registers an offense for a predicate method with a block' do
        expect_offense(<<~RUBY)
          expect(foo).to be_all { |x| x.present? }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_all(n) { |x| x.ok? }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_all { present }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_all { }
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
          expect(foo).to be_all do; end
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.

          expect(foo).to be_all do |x|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `all?` over `be_all` matcher.
            x + 1
            x >= 2
          end
        RUBY

        expect_correction(<<~RUBY)
          expect(foo.all? { |x| x.present? }).to #{matcher_true}
          expect(foo.all?(n) { |x| x.ok? }).to #{matcher_true}
          expect(foo.all? { present }).to #{matcher_true}
          expect(foo.all? { }).to #{matcher_true}
          expect(foo.all? do; end).to #{matcher_true}

          expect(foo.all? do |x|
            x + 1
            x >= 2
          end).to #{matcher_true}
        RUBY
      end
    end

    context 'when strict is true' do
      let(:strict) { true }

      include_examples 'explicit', 'be(true)', 'be(false)'
    end

    context 'when strict is false' do
      let(:strict) { false }

      include_examples 'explicit', 'be_truthy', 'be_falsey'
    end
  end
end
