RSpec.describe RuboCop::Cop::RSpec::ContextMethod do
  subject(:cop) { described_class.new }

  it 'skips describe blocks' do
    expect_no_offenses(<<-RUBY)
      describe '.foo_bar' do
      end

      describe '#foo_bar' do
      end
    RUBY
  end

  it 'finds context with `.` at the beginning' do
    expect_offense(<<-RUBY)
      context '.foo_bar' do
              ^^^^^^^^^^ Use describe for testing methods.
      end
    RUBY
  end

  it 'finds context with `#` at the beginning' do
    expect_offense(<<-RUBY)
      context '#foo_bar' do
              ^^^^^^^^^^ Use describe for testing methods.
      end
    RUBY
  end

  include_examples 'autocorrect',
                   'context ".foo_bar" do; end',
                   'describe ".foo_bar" do; end'

  include_examples 'autocorrect',
                   'context "#foo_bar" do; end',
                   'describe "#foo_bar" do; end'
end
