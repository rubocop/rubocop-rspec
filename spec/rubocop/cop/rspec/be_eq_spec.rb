# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::BeEq do
  it 'registers an offense for `eq` when argument is a boolean' do
    expect_offense(<<-RUBY)
      it { expect(foo).to eq(true) }
                          ^^ Prefer `be` over `eq`.
      it { expect(foo).not_to eq(true) }
                              ^^ Prefer `be` over `eq`.
      it { expect(foo).to_not eq(true) }
                              ^^ Prefer `be` over `eq`.
      it { expect(foo).to eq(false) }
                          ^^ Prefer `be` over `eq`.
      it { expect(foo).not_to eq(false) }
                              ^^ Prefer `be` over `eq`.
      it { expect(foo).to_not eq(false) }
                              ^^ Prefer `be` over `eq`.
    RUBY

    expect_correction(<<-RUBY)
      it { expect(foo).to be(true) }
      it { expect(foo).not_to be(true) }
      it { expect(foo).to_not be(true) }
      it { expect(foo).to be(false) }
      it { expect(foo).not_to be(false) }
      it { expect(foo).to_not be(false) }
    RUBY
  end

  it 'registers an offense for `eq` when argument is nil' do
    expect_offense(<<-RUBY)
      it { expect(foo).to eq(nil) }
                          ^^ Prefer `be` over `eq`.
      it { expect(foo).not_to eq(nil) }
                              ^^ Prefer `be` over `eq`.
      it { expect(foo).to_not eq(nil) }
                              ^^ Prefer `be` over `eq`.
    RUBY

    expect_correction(<<-RUBY)
      it { expect(foo).to be(nil) }
      it { expect(foo).not_to be(nil) }
      it { expect(foo).to_not be(nil) }
    RUBY
  end

  it 'does not register an offense for `eq` when argument is an integer' do
    expect_no_offenses(<<-RUBY)
      it { expect(foo).to eq(0) }
      it { expect(foo).to eq(123) }
    RUBY
  end

  it 'does not register an offense for `eq` when argument is a float' do
    expect_no_offenses(<<-RUBY)
      it { expect(foo).to eq(1.0) }
      it { expect(foo).to eq(1.23) }
    RUBY
  end

  it 'does not register an offense for `eq` when argument is a symbol' do
    expect_no_offenses(<<-RUBY)
      it { expect(foo).to eq(:foo) }
    RUBY
  end

  it 'does not register an offense for `eq` when argument is a string' do
    expect_no_offenses(<<-RUBY)
      it { expect(foo).to eq('foo') }
    RUBY
  end
end
