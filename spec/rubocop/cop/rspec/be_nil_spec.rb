# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::BeNil do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'with EnforcedStyle `be_nil`' do
    let(:enforced_style) { 'be_nil' }

    it 'registers an offense when using `#be` for `nil` value' do
      expect_offense(<<~RUBY)
        expect(foo).to be(nil)
                       ^^^^^^^ Prefer `be_nil` over `be(nil)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(foo).to be_nil
      RUBY
    end

    it 'does not register an offense when using `#be_nil`' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_nil
      RUBY
    end

    it 'does not register an offense when using `#be` with other values' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be(true)
        expect(foo).to be(false)
        expect(foo).to be(1)
        expect(foo).to be("yes")
        expect(foo).to be(Class.new)
      RUBY
    end
  end

  context 'with EnforcedStyle `be`' do
    let(:enforced_style) { 'be' }

    it 'does not register an offense when using `#be` for `nil` value' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be(nil)
      RUBY
    end

    it 'registers an offense when using `#be_nil`' do
      expect_offense(<<~RUBY)
        expect(foo).to be_nil
                       ^^^^^^ Prefer `be(nil)` over `be_nil`.
      RUBY

      expect_correction(<<~RUBY)
        expect(foo).to be(nil)
      RUBY
    end

    it 'does not register an offense when using other `#be_*` methods' do
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_truthy
        expect(foo).to be_falsey
        expect(foo).to be_fooish
      RUBY
    end
  end

  context 'with EnforcedStyle set but stubbed to `something_arbitrary` internally' do
    let(:enforced_style) { 'be' }

    it 'does not register any offenses' do
      allow_any_instance_of(described_class).to receive(:style).and_return('something_arbitrary')
      expect_no_offenses(<<~RUBY)
        expect(foo).to be_nil
        expect(foo).to be(nil)
      RUBY
    end
  end
end
