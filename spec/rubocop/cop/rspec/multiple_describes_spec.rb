describe RuboCop::Cop::RSpec::MultipleDescribes do
  subject(:cop) { described_class.new }

  include_examples 'an rspec only cop'

  it 'finds multiple top level describes with class and method' do
    expect_violation(<<-RUBY)
      describe MyClass, '.do_something' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use multiple top level describes - try to nest them.
      describe MyClass, '.do_something_else' do; end
    RUBY
  end

  it 'finds multiple top level describes only with class' do
    expect_violation(<<-RUBY)
      describe MyClass do; end
      ^^^^^^^^^^^^^^^^ Do not use multiple top level describes - try to nest them.
      describe MyOtherClass do; end
    RUBY
  end

  it 'skips single top level describe' do
    expect_no_violations(<<-RUBY)
      require 'spec_helper'

      describe MyClass do
      end
    RUBY
  end
end
