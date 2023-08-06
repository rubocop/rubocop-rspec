# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::NegationBeValid do
  let(:cop_config) { { 'EnforcedStyle' => enforced_style } }

  context 'with EnforcedStyle `not_to`' do
    let(:enforced_style) { 'not_to' }

    it 'registers an offense when using ' \
       '`expect(...).to be_invalid`' do
      expect_offense(<<~RUBY)
        expect(foo).to be_invalid
                    ^^^^^^^^^^^^^ Use `expect(...).not_to be_valid`.
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(...).not_to be_valid`' do
      expect_no_offenses(<<~RUBY)
        expect(foo).not_to be_valid
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(...).to be_valid`' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_valid
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(...).to be_invalid` and method chain' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_invalid.and be_odd
        expect(foo).to be_invalid.or be_even
      RUBY
    end
  end

  context 'with EnforcedStyle `be_invalid`' do
    let(:enforced_style) { 'be_invalid' }

    it 'registers an offense when using ' \
       '`expect(...).not_to be_valid`' do
      expect_offense(<<~RUBY)
        expect(foo).not_to be_valid
                    ^^^^^^^^^^^^^^^ Use `expect(...).to be_invalid`.
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(...).to be_invalid`' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_invalid
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(...).to be_valid`' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_valid
      RUBY
    end

    it 'does not register an offense when using ' \
       '`expect(...).not_to be_valid` and method chain' do
      expect_no_offenses(<<~RUBY)
        expect(foo).not_to be_valid.and be_odd
        expect(foo).not_to be_valid.or be_even
      RUBY
    end
  end
end
