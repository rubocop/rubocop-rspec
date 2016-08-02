describe RuboCop::Cop::RSpec::InstanceVariable do
  subject(:cop) { described_class.new }

  it 'finds an instance variable inside a describe' do
    expect_violation(<<-RUBY)
      describe MyClass do
        before { @foo = [] }
        it { expect(@foo).to be_empty }
                    ^^^^ Use `let` instead of an instance variable
      end
    RUBY
  end

  it 'ignores non-spec blocks' do
    expect_violation(<<-RUBY)
      not_rspec do
        before { @foo = [] }
        it { expect(@foo).to be_empty }
      end
    RUBY
  end

  it 'finds an instance variable inside a shared example' do
    expect_violation(<<-RUBY)
      shared_examples 'shared example' do
        it { expect(@foo).to be_empty }
                    ^^^^ Use `let` instead of an instance variable
      end
    RUBY
  end

  it 'ignores an instance variable without describe' do
    expect_violation(<<-RUBY)
      @foo = []
      @foo.empty?
    RUBY
  end
end
