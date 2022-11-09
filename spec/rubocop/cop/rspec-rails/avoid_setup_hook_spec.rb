# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpecRails::AvoidSetupHook do
  it 'registers an offense for `setup`' do
    expect_offense(<<~RUBY)
      setup do
      ^^^^^^^^ Use `before` instead of `setup`.
        allow(foo).to receive(:bar)
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(foo).to receive(:bar)
      end
    RUBY
  end

  it 'does not register an offense for `before`' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(foo).to receive(:bar)
      end
    RUBY
  end

  it 'does not register an offense for an unrelated `setup` call' do
    expect_no_offenses(<<~RUBY)
      navigation.setup do
        direction 'to infinity!'
      end
    RUBY
  end
end
