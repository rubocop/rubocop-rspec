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
end
