# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::RSpec::ExpectOutput do
  subject(:cop) { described_class.new }

  it 'registers an offense for overwriting $stdout within an example' do
    expect_violation(<<-RUBY)
      specify do
        $stdout = StringIO.new
        ^^^^^^^ Use `expect { ... }.to output(...).to_stdout` instead of mutating $stdout
      end
    RUBY
  end

  it 'registers an offense for overwriting $stderr ' \
     'within an example scoped hook' do
    expect_violation(<<-RUBY)
      before(:each) do
        $stderr = StringIO.new
        ^^^^^^^ Use `expect { ... }.to output(...).to_stderr` instead of mutating $stderr
      end
    RUBY
  end

  it 'does not register an offense for interacting with $stdout' do
    expect_no_violations(<<-RUBY)
      specify do
        $stdout.puts("hi")
      end
    RUBY
  end

  it 'does not flag assignments to other global variables' do
    expect_no_violations(<<-RUBY)
      specify do
        $blah = StringIO.new
      end
    RUBY
  end

  it 'does not flag assignments to $stdout outside of example scope' do
    expect_no_violations(<<-RUBY)
      before(:suite) do
        $stderr = StringIO.new
      end
    RUBY
  end

  it 'does not flag assignments to $stdout in example_group scope' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        $stderr = StringIO.new
      end
    RUBY
  end

  it 'does not flag assigns to $stdout when in the root scope' do
    expect_no_violations('$stderr = StringIO.new')
  end
end
