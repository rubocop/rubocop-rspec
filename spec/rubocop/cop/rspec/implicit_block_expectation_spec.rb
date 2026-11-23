# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ImplicitBlockExpectation do
  it 'flags lambda in subject' do
    expect_offense(<<~RUBY)
      describe do
        subject { -> { boom } }
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'ignores non-lambda subject' do
    expect_no_offenses(<<~RUBY)
      describe do
        subject { 'normal' }
        it { is_expected.to eq(something) }
      end
    RUBY
  end

  it 'flags lambda in subject!' do
    expect_offense(<<~RUBY)
      describe do
        subject! { -> { boom } }
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'flags literal lambda' do
    expect_offense(<<~RUBY)
      describe do
        subject! { lambda { boom } }
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'flags proc' do
    expect_offense(<<~RUBY)
      describe do
        subject! { proc { boom } }
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'flags Proc.new' do
    expect_offense(<<~RUBY)
      describe do
        subject! { Proc.new { boom } }
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'flags named subject' do
    expect_offense(<<~RUBY)
      describe do
        subject(:name) { -> { boom } }
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'flags when subject is defined in the outer example group' do
    expect_offense(<<~RUBY)
      describe do
        subject { -> { boom } }
        context do
          it { is_expected.to change { something }.to(new_value) }
               ^^^^^^^^^^^ Avoid implicit block expectations.
        end
      end
    RUBY
  end

  it 'ignores normal local subject' do
    expect_no_offenses(<<~RUBY)
      describe do
        subject { -> { boom } }
        context do
          subject { 'normal' }
          it { is_expected.to eq(something) }
        end
      end
    RUBY
  end

  it 'ignores named subject with deeply nested lambda' do
    expect_no_offenses(<<~RUBY)
      describe do
        subject { {hash: -> { boom }} }
        it { is_expected.to be(something) }
      end
    RUBY
  end

  it 'flags with `should` as implicit subject' do
    expect_offense(<<~RUBY)
      describe do
        subject { -> { boom } }
        it { should change { something }.to(new_value) }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'flags with `should_not` as implicit subject' do
    expect_offense(<<~RUBY)
      describe do
        subject { -> { boom } }
        it { should_not change { something }.to(new_value) }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end

  it 'ignores when there is no subject defined' do
    expect_no_offenses(<<~RUBY)
      shared_examples 'subject is defined somewhere else' do
        it { is_expected.to change { something }.to(new_value) }
      end
    RUBY
  end

  it 'ignores a block-pass subject' do
    expect_no_offenses(<<~RUBY)
      describe do
        subject(&blk)
        it { is_expected.to change { something }.to(new_value) }
      end
    RUBY
  end

  it 'ignores a block-pass subject nested in a group with a lambda subject' do
    expect_no_offenses(<<~RUBY)
      describe do
        subject { -> { boom } }

        context 'nested' do
          subject(:named, &blk)
          it { is_expected.to change { something }.to(new_value) }
        end
      end
    RUBY
  end

  it 'flags lambda in subject next to block-pass examples and hooks' do
    expect_offense(<<~RUBY)
      describe do
        subject { -> { boom } }
        before(&blk)
        it 'works', &blk
        it { is_expected.to change { something }.to(new_value) }
             ^^^^^^^^^^^ Avoid implicit block expectations.
      end
    RUBY
  end
end
