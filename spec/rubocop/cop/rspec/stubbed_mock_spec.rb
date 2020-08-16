# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::StubbedMock do
  subject(:cop) { described_class.new }

  it 'flags stubbed message expectation' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).and_return('hello world')
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags stubbed message expectation with a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar) { 'hello world' }
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags stubbed message expectation with argument matching' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42).and_return('hello world')
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags stubbed message expectation with argument matching and a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42) { 'hello world' }
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'ignores `have_received`' do
    expect_no_offenses('expect(foo).to have_received(:bar)')
  end

  it 'flags `receive_messages`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_messages(foo: 42, bar: 777)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags `receive_message_chain`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, bar: 777)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags `receive_message_chain` with `.and_return`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, :bar).and_return(777)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags `receive_message_chain` with a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, :bar) { 777 }
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags with order and count constraints', :pending do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar) { 'hello world' }.ordered
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive(:bar).ordered { 'hello world' }
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive(:bar).with(42).ordered { 'hello world' }
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive(:bar).once.with(42).ordered { 'hello world' }
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive(:bar) { 'hello world' }.once.with(42).ordered
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive(:bar).once.with(42).and_return('hello world').ordered
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags block-pass' do
    expect_offense(<<-RUBY)
      canned = -> { 42 }
      expect(foo).to receive(:bar, &canned)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive(:bar).with(42, &canned)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
      expect(foo).to receive_message_chain(:foo, :bar, &canned)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
    RUBY
  end

  it 'flags `is_expected`' do
    expect_offense(<<~RUBY)
      is_expected.to receive(:bar).and_return(:baz)
      ^^^^^^^^^^^ Prefer `allow(subject)` to `is_expected` when configuring a response.
    RUBY
  end

  it 'flags `expect_any_instance_of`' do
    expect_offense(<<~RUBY)
      expect_any_instance_of(Foo).to receive(:bar).and_return(:baz)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `allow_any_instance_of` to `expect_any_instance_of` when configuring a response.
    RUBY
  end

  it 'ignores message allowances' do
    expect_no_offenses(<<-RUBY)
      allow(foo).to receive(:bar).and_return('hello world')
      allow(foo).to receive(:bar) { 'hello world' }
      allow(foo).to receive(:bar).with(42).and_return('hello world')
      allow(foo).to receive(:bar).with(42) { 'hello world' }
      allow(foo).to receive_messages(foo: 42, bar: 777)
      allow(foo).to receive_message_chain(:foo, bar: 777)
      allow(foo).to receive_message_chain(:foo, :bar).and_return(777)
      allow(foo).to receive_message_chain(:foo, :bar) { 777 }
      allow(foo).to receive(:bar, &canned)
    RUBY
  end

  it 'tolerates passed arguments without parentheses' do
    expect_offense(<<-RUBY)
      expect(Foo)
      ^^^^^^^^^^^ Prefer `allow` to `expect` when configuring a response.
        .to receive(:new)
        .with(bar).and_return baz
    RUBY
  end
end
