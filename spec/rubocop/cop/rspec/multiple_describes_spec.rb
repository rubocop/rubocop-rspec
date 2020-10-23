# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MultipleDescribes do
  it 'flags multiple top-level example groups with class and method' do
    expect_offense(<<-RUBY)
      describe MyClass, '.do_something' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      describe MyClass, '.do_something_else' do; end
    RUBY
  end

  it 'flags multiple top-level example groups only with class' do
    expect_offense(<<-RUBY)
      describe MyClass do; end
      ^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      describe MyOtherClass do; end
    RUBY
  end

  it 'flags multiple top-level example groups with an arbitrary argument' do
    expect_offense(<<-RUBY)
      describe 'MyClass' do; end
      ^^^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      describe 'MyOtherClass' do; end
    RUBY
  end

  it 'flags multiple top-level example groups aliases' do
    expect_offense(<<-RUBY)
      example_group MyClass do; end
      ^^^^^^^^^^^^^^^^^^^^^ Do not use multiple top-level example groups - try to nest them.
      feature MyOtherClass do; end
    RUBY
  end

  it 'ignores single top-level example group' do
    expect_no_offenses(<<-RUBY)
      describe MyClass do
      end
    RUBY
  end

  it 'ignores multiple shared example groups' do
    expect_no_offenses(<<-RUBY)
      shared_examples_for 'behaves' do
      end
      shared_examples_for 'misbehaves' do
      end
      describe MyClass do
      end
    RUBY
  end
end
