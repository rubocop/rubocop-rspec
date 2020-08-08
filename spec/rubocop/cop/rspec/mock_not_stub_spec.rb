# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MockNotStub do
  subject(:cop) { described_class.new }

  it 'flags stubbed message expectation' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).and_return("hello world")
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags stubbed message expectation with a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar) { "hello world" }
                                   ^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags stubbed message expectation with argument matching' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42).and_return("hello world")
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags stubbed message expectation with argument matching and a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42) { "hello world" }
                                            ^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'ignores `have_received`' do
    expect_no_offenses('expect(foo).to have_received(:bar)')
  end

  it 'flags `receive_messages`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_messages(foo: 42, bar: 777)
                                      ^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags `receive_message_chain`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, bar: 777)
                                                 ^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags `receive_message_chain` with `.and_return`' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, :bar).and_return(777)
                                                      ^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags `receive_message_chain` with a block' do
    expect_offense(<<-RUBY)
      expect(foo).to receive_message_chain(:foo, :bar) { 777 }
                                                       ^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags block-pass' do
    expect_offense(<<-RUBY)
      canned = -> { 42 }
      expect(foo).to receive(:bar, &canned)
                                   ^^^^^^^ Don't stub your mock.
      expect(foo).to receive(:bar).with(42, &canned)
                                            ^^^^^^^ Don't stub your mock.
      expect(foo).to receive_message_chain(:foo, :bar, &canned)
                                                       ^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'ignores message allowances' do
    expect_no_offenses(<<-RUBY)
    RUBY
  end
end
