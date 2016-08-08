# encoding: utf-8

describe RuboCop::Cop::RSpec::HookArgument do
  subject(:cop) { described_class.new }

  it 'detects :each for hooks' do
    expect_violation(<<-RUBY)
      before(:each) { true }
             ^^^^^ Omit the default `:each` argument for RSpec hooks.
      after(:each)  { true }
            ^^^^^ Omit the default `:each` argument for RSpec hooks.
      around(:each) { true }
             ^^^^^ Omit the default `:each` argument for RSpec hooks.
    RUBY
  end

  it 'detects :example for hooks' do
    expect_violation(<<-RUBY)
      before(:example) { true }
             ^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
      after(:example)  { true }
            ^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
      around(:example) { true }
             ^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
    RUBY
  end

  it 'ignores :context and :suite' do
    expect_no_violations(<<-RUBY)
      before(:suite) { true }
      after(:suite) { true }
      before(:context) { true }
      after(:context) { true }
    RUBY
  end

  it 'ignores hooks with more than one argument' do
    expect_no_violations(<<-RUBY)
      before(:each, :something_custom) { true }
    RUBY
  end

  it 'ignores non-rspec hooks' do
    expect_no_violations(<<-RUBY)
      setup(:each) { true }
    RUBY
  end

  it 'does not flag hooks without default scopes' do
    expect_no_violations(<<-RUBY)
      before { true }
      after { true }
      before { true }
      after { true }
    RUBY
  end
end
