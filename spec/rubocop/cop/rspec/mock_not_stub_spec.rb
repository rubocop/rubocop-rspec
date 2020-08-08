# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MockNotStub do
  subject(:cop) { described_class.new }

  it 'flags stubbed message expectation' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).and_return('hello world')
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags stubbed message expectation with a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar) { 'hello world' }
                                   ^^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags stubbed message expectation with argument matching' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42).and_return('hello world')
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags stubbed message expectation with argument matching and a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42) { 'hello world' }
                                            ^^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'ignores `have_received`' do
    expect_no_offenses('expect(foo).to have_received(:bar)')
  end

  it 'flags `receive_messages`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_messages(foo: 42, bar: 777)
                                      ^^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags `receive_message_chain`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, bar: 777)
                                                 ^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags `receive_message_chain` with `.and_return`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, :bar).and_return(777)
                                                      ^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags `receive_message_chain` with a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, :bar) { 777 }
                                                       ^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags with order and count constraints', :pending do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar) { 'hello world' }.ordered
                                   ^^^^^^^^^^^^^^^^^ Do not stub your mock.
      expect(foo).to receive(:bar).ordered { 'hello world' }
                                           ^^^^^^^^^^^^^^^^^ Do not stub your mock.
      expect(foo).to receive(:bar).with(42).ordered { 'hello world' }
                                                    ^^^^^^^^^^^^^^^^^ Do not stub your mock.
      expect(foo).to receive(:bar).once.with(42).ordered { 'hello world' }
                                                         ^^^^^^^^^^^^^^^^^ Do not stub your mock.
      expect(foo).to receive(:bar) { 'hello world' }.once.with(42).ordered
                                   ^^^^^^^^^^^^^^^^^ Do not stub your mock.
      expect(foo).to receive(:bar).once.with(42).and_return('hello world').ordered
                                                 ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'flags block-pass' do
    expect_offense(<<-RUBY)
      canned = -> { 42 }
      expect(foo).to receive(:bar, &canned)
                                   ^^^^^^^ Do not stub your mock.
      expect(foo).to receive(:bar).with(42, &canned)
                                            ^^^^^^^ Do not stub your mock.
      expect(foo).to receive_message_chain(:foo, :bar, &canned)
                                                       ^^^^^^^ Do not stub your mock.
    RUBY
  end

  it 'ignores message allowances' do
    expect_no_offenses(<<-RUBY)
    RUBY
  end
end
