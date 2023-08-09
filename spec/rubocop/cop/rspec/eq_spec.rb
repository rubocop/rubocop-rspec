# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Eq do
  it 'registers an offense when using `be ==`' do
    expect_offense(<<~RUBY)
      it { expect(foo).to be == true }
                          ^^^^^ Use `eq` instead of `be ==` to compare objects.
      it { expect(bar).not_to be == 1 }
                              ^^^^^ Use `eq` instead of `be ==` to compare objects.
    RUBY

    expect_correction(<<~RUBY)
      it { expect(foo).to eq true }
      it { expect(bar).not_to eq 1 }
    RUBY
  end

  it 'does not register an offense when using `eq`' do
    expect_no_offenses(<<~RUBY)
      it { expect(foo).to eq true }
    RUBY
  end
end
