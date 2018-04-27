RSpec.describe RuboCop::Cop::RSpec::DescribeMethodFormat do
  subject(:cop) { described_class.new }

  it 'ignores describes with class' do
    expect_no_offenses('describe Some::Class do; end')
  end

  it 'enforces non-method names' do
    expect_offense(<<-RUBY)
      describe 'incorrect_usage' do
               ^^^^^^^^^^^^^^^^^ Use # for instance methods or . for class methods when describing class method
      end
    RUBY
  end

  it 'skips methods starting with a . or #' do
    expect_no_offenses(<<-RUBY)
      describe '.foo' do
      end

      describe '#bar' do
      end
    RUBY
  end

  it 'skips specs having a string second argument' do
    expect_no_offenses(<<-RUBY)
      describe Some::Class, "config" do
      end
    RUBY
  end
end
