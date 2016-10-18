# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MockNotStub do
  subject(:cop) { described_class.new }

  it 'flags expect(...).to receive(...).with(...).and_return' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42).and_return("hello world")
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags expect(...).to receive(...).with(...) { } ' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).with(42) { "hello world" }
                                            ^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags expect(...).to receive(...).and_return' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar).and_return("hello world")
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'flags expect(...).to receive(...) { } ' do
    expect_offense(<<-RUBY)
      expect(foo).to receive(:bar) { "hello world" }
                                   ^^^^^^^^^^^^^^^^^ Don't stub your mock.
    RUBY
  end

  it 'approves of expect(...).to have_received' do
    expect_no_offenses('expect(foo).to have_received(:bar)')
  end
end
