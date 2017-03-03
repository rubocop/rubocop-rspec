RSpec.describe RuboCop::Cop::RSpec::AroundBlock do
  subject(:cop) { described_class.new }

  it 'finds `around` block without block arguments' do
    expect_violation(<<-RUBY)
      around do
      ^^^^^^^^^ Test object should be passed to around block
        do_something
      end
    RUBY
  end

  it 'finds `around` block with unused argument' do
    expect_violation(<<-RUBY)
      around do |test|
                 ^^^^ You should call `test.call` or `test.run`
        do_something
      end
    RUBY
  end

  it 'checks the first argument of the block' do
    expect_violation(<<-RUBY)
      around do |test, unused|
                 ^^^^ You should call `test.call` or `test.run`
        unused.run
      end
    RUBY
  end
end
