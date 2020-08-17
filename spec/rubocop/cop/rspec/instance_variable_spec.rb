# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::InstanceVariable do
  it 'flags an instance variable inside a describe' do
    expect_offense(<<-RUBY)
      describe MyClass do
        before { @foo = [] }
        it { expect(@foo).to be_empty }
                    ^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
      end
    RUBY
  end

  it 'ignores non-spec blocks' do
    expect_no_offenses(<<-RUBY)
      not_rspec do
        before { @foo = [] }
        it { expect(@foo).to be_empty }
      end
    RUBY
  end

  it 'flags an instance variable inside a shared example' do
    expect_offense(<<-RUBY)
      shared_examples 'shared example' do
        it { expect(@foo).to be_empty }
                    ^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
      end
    RUBY
  end

  it 'flags several instance variables inside a describe' do
    expect_offense(<<-RUBY)
      describe MyClass do
        before { @foo = [] }
        it { expect(@foo).to be_empty }
                    ^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
        it { expect(@bar).to be_empty }
                    ^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
      end
    RUBY
  end

  it 'ignores an instance variable without describe' do
    expect_no_offenses(<<-RUBY)
      @foo = []
      @foo.empty?
    RUBY
  end

  it 'ignores an instance variable inside a dynamic class' do
    expect_no_offenses(<<-RUBY)
      describe MyClass do
        let(:object) do
          Class.new(OtherClass) do
            def initialize(resource)
              @resource = resource
            end

            def serialize
              @resource.to_json
            end
          end
        end
      end
    RUBY
  end

  # Regression test for nevir/rubocop-rspec#115
  it 'ignores instance variables outside of specs' do
    expect_no_offenses(<<-RUBY, 'lib/source_code.rb')
      feature do
        @foo = bar

        @foo
      end
    RUBY
  end

  context 'when used in a custom matcher' do
    it 'ignores instance variables inside `matcher`' do
      expect_no_offenses(<<~RUBY)
        describe MyClass do
          matcher :have_color do
            match do |object|
              @matcher = have_attributes(color: anything)
              @matcher.matches?(object)
            end

            failure_message do
              @matcher.failure_message
            end
          end
        end
      RUBY
    end

    it 'flags instance variables outside `matcher`' do
      expect_offense(<<~RUBY)
        describe MyClass do
          matcher :have_color do
            match do |object|
              @matcher = have_attributes(color: anything)
              @matcher.matches?(object)
            end
          end

          it { expect(color: 1).to @matcher }
                                   ^^^^^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
        end
      RUBY
    end

    it 'ignores instance variables inside `RSpec::Matchers.define`' do
      expect_no_offenses(<<~RUBY)
        describe MyClass do
          RSpec::Matchers.define :be_bigger_than do |first|
            match do |actual|
              (actual > first) && (actual < @second)
            end

            chain :and_smaller_than do |second|
              @second = second
            end
          end
        end
      RUBY
    end
  end

  context 'when configured with AssignmentOnly' do
    let(:cop_config) do
      { 'AssignmentOnly' => true }
    end

    it 'flags an instance variable when it is also assigned' do
      expect_offense(<<-RUBY)
        describe MyClass do
          before { @foo = [] }
          it { expect(@foo).to be_empty }
                      ^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
        end
      RUBY
    end

    it 'ignores an instance variable when it is not assigned' do
      expect_no_offenses(<<-RUBY)
        describe MyClass do
          it { expect(@foo).to be_empty }
        end
      RUBY
    end

    it 'flags an instance variable when it is also assigned ' \
       'in a sibling example group' do
      expect_offense(<<-RUBY)
        describe MyClass do
          context 'foo' do
            before { @foo = [] }
          end

          it { expect(@foo).to be_empty }
                      ^^^^ Avoid instance variables – use let, a method call, or a local variable (if possible).
        end
      RUBY
    end
  end
end
