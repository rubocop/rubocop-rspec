describe RuboCop::Cop::RSpec::EmptyLineBetweenExamples do
  subject(:cop) { described_class.new }

  it 'reports an offense when examples specs are not separated by a space' do
    expect_violation(<<-RUBY)
    describe Foo do
      it 'works' do
        blah
      end

      it 'does x' do
        blah
      end
      it 'does y' do
      ^^^^^^^^^^^^^^ Use empty lines between examples.
        blah
      end
    end
    RUBY
  end

  it 'does not report an offense when the examples are separated by a space' do
    expect_no_violations(<<-RUBY)
    describe Foo do
      it 'does x' do
        blah
      end

      it 'does y' do
        blah
      end
    end
    RUBY
  end
end
