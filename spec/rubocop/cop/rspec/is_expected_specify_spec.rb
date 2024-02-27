# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IsExpectedSpecify, :config do
  it 'registers an offense when using `specify` and one-liner style' do
    expect_offense(<<~RUBY)
      specify { is_expected.to be_truthy }
      ^^^^^^^ Use `it` instead of `specify`.
      specify { are_expected.to be_falsy }
      ^^^^^^^ Use `it` instead of `specify`.
    RUBY

    expect_correction(<<~RUBY)
      it { is_expected.to be_truthy }
      it { are_expected.to be_falsy }
    RUBY
  end

  it 'does not register an offense when using `specify` ' \
     'and not one-liner style' do
    expect_no_offenses(<<~RUBY)
      specify { expect(sqrt(4)).to eq(2) }
    RUBY
  end

  it 'does not register an offense when using `specify` and multi line' do
    expect_no_offenses(<<~RUBY)
      specify do
        is_expected.to be_truthy
      end
    RUBY
  end

  it 'does not register an offense when using `it` and one-liner style' do
    expect_no_offenses(<<~RUBY)
      it { is_expected.to be_truthy }
    RUBY
  end

  it 'does not register an offense when using `specify` with metadata' do
    expect_no_offenses(<<~RUBY)
      specify "pending", :pending
    RUBY
  end
end
