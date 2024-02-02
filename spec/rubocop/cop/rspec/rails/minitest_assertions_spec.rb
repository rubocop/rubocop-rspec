# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::MinitestAssertions do
  context 'with equal assertions' do
    it 'registers an offense when using `assert_equal`' do
      expect_offense(<<~RUBY)
        assert_equal(a, b)
        ^^^^^^^^^^^^^^^^^^ Use `expect(b).to eq(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to eq(a)
      RUBY
    end

    it 'registers an offense when using `assert_equal` with no parentheses' do
      expect_offense(<<~RUBY)
        assert_equal a, b
        ^^^^^^^^^^^^^^^^^ Use `expect(b).to eq(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to eq(a)
      RUBY
    end

    it 'registers an offense when using `assert_equal` with failure message' do
      expect_offense(<<~RUBY)
        assert_equal a, b, "must be equal"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(eq(a), "must be equal")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(eq(a), "must be equal")
      RUBY
    end

    it 'registers an offense when using `assert_equal` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_equal(a,
        ^^^^^^^^^^^^^^^ Use `expect(b).to(eq(a), "must be equal")`.
                      b,
                      "must be equal")
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(eq(a), "must be equal")
      RUBY
    end

    it 'registers an offense when using `assert_not_equal`' do
      expect_offense(<<~RUBY)
        assert_not_equal a, b
        ^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).not_to eq(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to eq(a)
      RUBY
    end

    it 'registers an offense when using `refute_equal`' do
      expect_offense(<<~RUBY)
        refute_equal a, b
        ^^^^^^^^^^^^^^^^^ Use `expect(b).not_to eq(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to eq(a)
      RUBY
    end

    it 'does not register an offense when using `expect(b).to eq(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).to eq(a)
      RUBY
    end

    it 'does not register an offense when using `expect(b).not_to eq(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).not_to eq(a)
      RUBY
    end
  end

  context 'with instance_of assertions' do
    it 'registers an offense when using `assert_instance_of`' do
      expect_offense(<<~RUBY)
        assert_instance_of(a, b)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_an_instance_of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to be_an_instance_of(a)
      RUBY
    end

    it 'registers an offense when using `assert_instance_of` with ' \
       'no parentheses' do
      expect_offense(<<~RUBY)
        assert_instance_of a, b
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_an_instance_of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to be_an_instance_of(a)
      RUBY
    end

    it 'registers an offense when using `assert_instance_of` with' \
       'failure message' do
      expect_offense(<<~RUBY)
        assert_instance_of a, b, "must be instance of"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(be_an_instance_of(a), "must be instance of")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(be_an_instance_of(a), "must be instance of")
      RUBY
    end

    it 'registers an offense when using `assert_instance_of` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_instance_of(a,
        ^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(be_an_instance_of(a), "must be instance of")`.
                      b,
                      "must be instance of")
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(be_an_instance_of(a), "must be instance of")
      RUBY
    end

    it 'registers an offense when using `assert_not_instance_of`' do
      expect_offense(<<~RUBY)
        assert_not_instance_of a, b
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).not_to be_an_instance_of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to be_an_instance_of(a)
      RUBY
    end

    it 'registers an offense when using `refute_instance_of`' do
      expect_offense(<<~RUBY)
        refute_instance_of a, b
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).not_to be_an_instance_of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to be_an_instance_of(a)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).to be_an_instance_of(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).to be_an_instance_of(a)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).not_to be_an_instance_of(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).not_to be_an_instance_of(a)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).to be_instance_of(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).to be_instance_of(a)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).not_to be_instance_of(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).not_to be_instance_of(a)
      RUBY
    end
  end

  context 'with includes assertions' do
    it 'registers an offense when using `assert_includes`' do
      expect_offense(<<~RUBY)
        assert_includes(a, b)
        ^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to include(b)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to include(b)
      RUBY
    end

    it 'registers an offense when using `assert_includes` with ' \
       'no parentheses' do
      expect_offense(<<~RUBY)
        assert_includes a, b
        ^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to include(b)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to include(b)
      RUBY
    end

    it 'registers an offense when using `assert_includes` with ' \
       'failure message' do
      expect_offense(<<~RUBY)
        assert_includes a, b, "must be include"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to(include(b), "must be include")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(include(b), "must be include")
      RUBY
    end

    it 'registers an offense when using `assert_includes` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_includes(a,
        ^^^^^^^^^^^^^^^^^^ Use `expect(a).to(include(b), "must be include")`.
                      b,
                      "must be include")
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(include(b), "must be include")
      RUBY
    end

    it 'registers an offense when using `assert_not_includes`' do
      expect_offense(<<~RUBY)
        assert_not_includes a, b
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).not_to include(b)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to include(b)
      RUBY
    end

    it 'registers an offense when using `refute_includes`' do
      expect_offense(<<~RUBY)
        refute_includes a, b
        ^^^^^^^^^^^^^^^^^^^^ Use `expect(a).not_to include(b)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to include(b)
      RUBY
    end

    it 'does not register an offense when using `expect(a).to include(b)`' do
      expect_no_offenses(<<~RUBY)
        expect(a).to include(b)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(a).not_to include(b)`' do
      expect_no_offenses(<<~RUBY)
        expect(a).not_to include(b)
      RUBY
    end
  end

  context 'with in_delta assertions' do
    it 'registers an offense when using `assert_in_delta`' do
      expect_offense(<<~RUBY)
        assert_in_delta(a, b)
        ^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_within(0.001).of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to be_within(0.001).of(a)
      RUBY
    end

    it 'registers an offense when using `assert_in_delta` with ' \
       'no parentheses' do
      expect_offense(<<~RUBY)
        assert_in_delta a, b
        ^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_within(0.001).of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to be_within(0.001).of(a)
      RUBY
    end

    it 'registers an offense when using `assert_in_delta` with ' \
       'a custom delta' do
      expect_offense(<<~RUBY)
        assert_in_delta a, b, 1
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_within(1).of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to be_within(1).of(a)
      RUBY
    end

    it 'registers an offense when using `assert_in_delta` with ' \
       'a custom delta from a variable' do
      expect_offense(<<~RUBY)
        delta = 1

        assert_in_delta a, b, delta
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_within(delta).of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        delta = 1

        expect(b).to be_within(delta).of(a)
      RUBY
    end

    it 'registers an offense when using `assert_in_delta` with ' \
       'a custom delta and a failure message' do
      expect_offense(<<~RUBY)
        assert_in_delta a, b, 1, "must be within delta"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(be_within(1).of(a), "must be within delta")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(be_within(1).of(a), "must be within delta")
      RUBY
    end

    it 'registers an offense when using `assert_in_delta` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_in_delta(a,
        ^^^^^^^^^^^^^^^^^^ Use `expect(b).to be_within(1).of(a)`.
                      b,
                      1)
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to be_within(1).of(a)
      RUBY
    end

    it 'registers an offense when using `assert_not_in_delta`' do
      expect_offense(<<~RUBY)
        assert_not_in_delta a, b
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).not_to be_within(0.001).of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to be_within(0.001).of(a)
      RUBY
    end

    it 'registers an offense when using `refute_in_delta`' do
      expect_offense(<<~RUBY)
        refute_in_delta a, b
        ^^^^^^^^^^^^^^^^^^^^ Use `expect(b).not_to be_within(0.001).of(a)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to be_within(0.001).of(a)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).to be_within(1).of(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).to be_within(1).of(a)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).not_to be_within(1).of(a)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).not_to be_within(1).of(a)
      RUBY
    end
  end

  context 'with match assertions' do
    it 'registers an offense when using `assert_match`' do
      expect_offense(<<~RUBY)
        assert_match(/xyz/, b)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to match(/xyz/)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to match(/xyz/)
      RUBY
    end

    it 'registers an offense when using `assert_match` with no parentheses' do
      expect_offense(<<~RUBY)
        assert_match /xyz/, b
        ^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to match(/xyz/)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to match(/xyz/)
      RUBY
    end

    it 'registers an offense when using `assert_match` with failure message' do
      expect_offense(<<~RUBY)
        assert_match /xyz/, b, "must match"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(match(/xyz/), "must match")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(match(/xyz/), "must match")
      RUBY
    end

    it 'registers an offense when using `assert_match` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_match(/xyz/,
        ^^^^^^^^^^^^^^^^^^^ Use `expect(b).to(match(/xyz/), "must match")`.
                      b,
                      "must match")
      RUBY

      expect_correction(<<~RUBY)
        expect(b).to(match(/xyz/), "must match")
      RUBY
    end

    it 'registers an offense when using `refute_match`' do
      expect_offense(<<~RUBY)
        refute_match /xyz/, b
        ^^^^^^^^^^^^^^^^^^^^^ Use `expect(b).not_to match(/xyz/)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(b).not_to match(/xyz/)
      RUBY
    end

    it 'does not register an offense when using `expect(b).to match(/xyz/)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).to match(/xyz/)
      RUBY
    end

    it 'does not register an offense when ' \
       'using `expect(b).not_to match(/xyz/)`' do
      expect_no_offenses(<<~RUBY)
        expect(b).not_to match(/xyz/)
      RUBY
    end
  end

  context 'with nil assertions' do
    it 'registers an offense when using `assert_nil`' do
      expect_offense(<<~RUBY)
        assert_nil(a)
        ^^^^^^^^^^^^^ Use `expect(a).to eq(nil)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to eq(nil)
      RUBY
    end

    it 'registers an offense when using `assert_nil` with no parentheses' do
      expect_offense(<<~RUBY)
        assert_nil a
        ^^^^^^^^^^^^ Use `expect(a).to eq(nil)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to eq(nil)
      RUBY
    end

    it 'registers an offense when using `assert_nil` with failure message' do
      expect_offense(<<~RUBY)
        assert_nil a, "must be nil"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to(eq(nil), "must be nil")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(eq(nil), "must be nil")
      RUBY
    end

    it 'registers an offense when using `assert_nil` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_nil(a,
        ^^^^^^^^^^^^^ Use `expect(a).to(eq(nil), "must be nil")`.
                      "must be nil")
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(eq(nil), "must be nil")
      RUBY
    end

    it 'registers an offense when using `assert_not_nil`' do
      expect_offense(<<~RUBY)
        assert_not_nil a
        ^^^^^^^^^^^^^^^^ Use `expect(a).not_to eq(nil)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to eq(nil)
      RUBY
    end

    it 'registers an offense when using `refute_nil`' do
      expect_offense(<<~RUBY)
        refute_nil a
        ^^^^^^^^^^^^ Use `expect(a).not_to eq(nil)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to eq(nil)
      RUBY
    end

    it 'does not register an offense when using `expect(a).to eq(nil)`' do
      expect_no_offenses(<<~RUBY)
        expect(a).to eq(nil)
      RUBY
    end

    it 'does not register an offense when using `expect(a).not_to eq(nil)`' do
      expect_no_offenses(<<~RUBY)
        expect(a).not_to eq(nil)
      RUBY
    end
  end

  context 'with empty assertions' do
    it 'registers an offense when using `assert_empty`' do
      expect_offense(<<~RUBY)
        assert_empty(a)
        ^^^^^^^^^^^^^^^ Use `expect(a).to be_empty`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to be_empty
      RUBY
    end

    it 'registers an offense when using `assert_empty` with no parentheses' do
      expect_offense(<<~RUBY)
        assert_empty a
        ^^^^^^^^^^^^^^ Use `expect(a).to be_empty`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to be_empty
      RUBY
    end

    it 'registers an offense when using `assert_empty` with failure message' do
      expect_offense(<<~RUBY)
        assert_empty a, "must be empty"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to(be_empty, "must be empty")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(be_empty, "must be empty")
      RUBY
    end

    it 'registers an offense when using `assert_empty` with ' \
       'multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_empty(a,
        ^^^^^^^^^^^^^^^ Use `expect(a).to(be_empty, "must be empty")`.
                      "must be empty")
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(be_empty, "must be empty")
      RUBY
    end

    it 'registers an offense when using `assert_not_empty`' do
      expect_offense(<<~RUBY)
        assert_not_empty a
        ^^^^^^^^^^^^^^^^^^ Use `expect(a).not_to be_empty`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to be_empty
      RUBY
    end

    it 'registers an offense when using `refute_empty`' do
      expect_offense(<<~RUBY)
        refute_empty a
        ^^^^^^^^^^^^^^ Use `expect(a).not_to be_empty`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to be_empty
      RUBY
    end

    it 'does not register an offense when using `expect(a).to be_empty`' do
      expect_no_offenses(<<~RUBY)
        expect(a).to be_empty
      RUBY
    end

    it 'does not register an offense when using `expect(a).not_to be_empty`' do
      expect_no_offenses(<<~RUBY)
        expect(a).not_to be_empty
      RUBY
    end
  end

  context 'with predicate assertions' do
    it 'registers an offense when using `assert_predicate` with ' \
       'an actual predicate' do
      expect_offense(<<~RUBY)
        assert_predicate(a, :valid?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to be_valid`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to be_valid
      RUBY
    end

    it 'registers an offense when using `assert_predicate` with ' \
       'an actual predicate and no parentheses' do
      expect_offense(<<~RUBY)
        assert_predicate a, :valid?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to be_valid`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to be_valid
      RUBY
    end

    it 'registers an offense when using `assert_predicate` with ' \
       'an actual predicate and a failure message' do
      expect_offense(<<~RUBY)
        assert_predicate a, :valid?, "must be valid"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).to(be_valid, "must be valid")`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(be_valid, "must be valid")
      RUBY
    end

    it 'registers an offense when using `assert_predicate` with ' \
       'an actual predicate and multi-line arguments' do
      expect_offense(<<~RUBY)
        assert_predicate(a,
        ^^^^^^^^^^^^^^^^^^^ Use `expect(a).to(be_valid, "must be valid")`.
                      :valid?,
                      "must be valid")
      RUBY

      expect_correction(<<~RUBY)
        expect(a).to(be_valid, "must be valid")
      RUBY
    end

    it 'registers an offense when using `assert_not_predicate` with ' \
       'an actual predicate' do
      expect_offense(<<~RUBY)
        assert_not_predicate a, :valid?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).not_to be_valid`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to be_valid
      RUBY
    end

    it 'registers an offense when using `refute_predicate` with ' \
       'an actual predicate' do
      expect_offense(<<~RUBY)
        refute_predicate a, :valid?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(a).not_to be_valid`.
      RUBY

      expect_correction(<<~RUBY)
        expect(a).not_to be_valid
      RUBY
    end

    it 'does not register an offense when using `expect(a).to be_predicate`' do
      expect_no_offenses(<<~RUBY)
        expect(a).to be_predicate
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(a).not_to be_predicate`' do
      expect_no_offenses(<<~RUBY)
        expect(a).not_to be_predicate
      RUBY
    end

    it 'does not register an offense when using `assert_predicate` with ' \
       'not a predicate' do
      expect_no_offenses(<<~RUBY)
        assert_predicate foo, :do_something
      RUBY
    end

    it 'does not register an offense when using `assert_not_predicate` with ' \
       'not a predicate' do
      expect_no_offenses(<<~RUBY)
        assert_not_predicate foo, :do_something
      RUBY
    end

    it 'does not register an offense when using `refute_predicate` with ' \
       'not a predicate' do
      expect_no_offenses(<<~RUBY)
        refute_predicate foo, :do_something
      RUBY
    end

    it 'does not register an offense when the predicate is not a symbol' do
      expect_no_offenses(<<~RUBY)
        assert_predicate a, 1
      RUBY
    end

    it 'does not register an offense when the predicate is missing' do
      expect_no_offenses(<<~RUBY)
        assert_predicate a, "whoops, we forgot about the actual predicate!"
      RUBY
    end

    it 'does not register an offense when the predicate is a variable' do
      expect_no_offenses(<<~RUBY)
        foo = :foo?

        assert_predicate a, foo
      RUBY
    end
  end
end
