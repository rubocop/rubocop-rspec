# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Yield do
  subject(:cop) { described_class.new }

  it 'flags `block.call`' do
    expect_offense(<<-RUBY)
      allow(foo).to receive(:bar) { |&block| block.call }
                                  ^^^^^^^^^^^^^^^^^^^^^^^ Use `.and_yield`.
    RUBY

    expect_correction(<<-RUBY)
      allow(foo).to receive(:bar).and_yield
    RUBY
  end

  it 'flags multiple `block.call`' do
    expect_offense(<<-RUBY)
      allow(foo).to receive(:bar) do |&block|
                                  ^^^^^^^^^^^ Use `.and_yield`.
        block.call
        block.call
      end
    RUBY

    expect_correction(<<-RUBY)
      allow(foo).to receive(:bar).and_yield.and_yield
    RUBY
  end

  it 'flags `block.call` with arguments' do
    expect_offense(<<-RUBY)
      allow(foo).to receive(:bar) { |&block| block.call(1, 2) }
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `.and_yield`.
    RUBY

    expect_correction(<<-RUBY)
      allow(foo).to receive(:bar).and_yield(1, 2)
    RUBY
  end

  it 'flags multiple `block.call` with arguments' do
    expect_offense(<<-RUBY)
      allow(foo).to receive(:bar) do |&block|
                                  ^^^^^^^^^^^ Use `.and_yield`.
         block.call(1)
         block.call(2)
       end
    RUBY

    expect_correction(<<-RUBY)
      allow(foo).to receive(:bar).and_yield(1).and_yield(2)
    RUBY
  end

  it 'flags `block.call` when `receive` is chained' do
    expect_offense(<<-RUBY)
      allow(foo).to receive(:bar).with(anything) { |&block| block.call }
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ Use `.and_yield`.
    RUBY

    expect_correction(<<-RUBY)
      allow(foo).to receive(:bar).with(anything).and_yield
    RUBY
  end

  it 'ignores `receive` with no block arguments' do
    expect_no_offenses(<<-RUBY)
      allow(foo).to receive(:bar) { |block| block.call }
    RUBY
  end

  it 'ignores stub when `block.call` is not the only statement' do
    expect_no_offenses(<<-RUBY)
      allow(foo).to receive(:bar) do |&block|
        result = block.call
        transform(result)
      end
    RUBY
  end
end
