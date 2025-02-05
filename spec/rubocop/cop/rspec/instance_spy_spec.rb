# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::InstanceSpy do
  context 'when used with `have_received`' do
    it 'adds an offense for an instance_double with single argument' do
      expect_offense(<<~RUBY)
        it do
          foo = instance_double(Foo).as_null_object
                ^^^^^^^^^^^^^^^^^^^^ Use `instance_spy` when you check your double with `have_received`.
          expect(foo).to have_received(:bar)
        end
      RUBY

      expect_correction(<<~RUBY)
        it do
          foo = instance_spy(Foo)
          expect(foo).to have_received(:bar)
        end
      RUBY
    end

    it 'adds an offense for an instance_double with multiple arguments' do
      expect_offense(<<~RUBY)
        it do
          foo = instance_double(Foo, :name).as_null_object
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `instance_spy` when you check your double with `have_received`.
          expect(foo).to have_received(:bar)
        end
      RUBY

      expect_correction(<<~RUBY)
        it do
          foo = instance_spy(Foo, :name)
          expect(foo).to have_received(:bar)
        end
      RUBY
    end

    it 'ignores instance_double when it is not used with as_null_object' do
      expect_no_offenses(<<~RUBY)
        it do
          foo = instance_double(Foo)
          expect(bar).to have_received(:bar)
        end
      RUBY
    end

    it 'ignores instance_double when expect is called on another variable' do
      expect_no_offenses(<<~RUBY)
        it do
          foo = instance_double(Foo).as_null_object
          bar = instance_spy(Bar).as_null_object
          expect(bar).to have_received(:baz)
        end
      RUBY
    end
  end

  context 'when not used with `have_received`' do
    it 'does not add an offense' do
      expect_no_offenses(<<~RUBY)
        it do
          foo = instance_double(Foo).as_null_object
          expect(bar).to have_received(:bar)
        end
      RUBY
    end
  end
end
