# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ReturnFromStub, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'with EnforcedStyle `and_return`' do
    let(:enforced_style) { 'and_return' }

    it 'finds static values returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { 42 }
                                      ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return(42)
        end
      RUBY
    end

    it 'finds empty values returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) {}
                                      ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return(nil)
        end
      RUBY
    end

    it 'finds array with only static values returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { [42, 43] }
                                      ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return([42, 43])
        end
      RUBY
    end

    it 'finds hash with only static values returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { {a: 42, b: 43} }
                                      ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return({a: 42, b: 43})
        end
      RUBY
    end

    it 'finds static values in a block when there are chained methods' do
      expect_offense(<<-RUBY)
        it do
          allow(Question).to receive(:meaning).with(:universe) { 42 }
                                                               ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Question).to receive(:meaning).with(:universe).and_return(42)
        end
      RUBY
    end

    it 'finds constants returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { Life::MEANING }
                                      ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return(Life::MEANING)
        end
      RUBY
    end

    it 'finds nested constants returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { {Life::MEANING => 42} }
                                      ^ Use `and_return` for static values.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return({Life::MEANING => 42})
        end
      RUBY
    end

    it 'ignores dynamic values returned from block' do
      expect_no_offenses(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { baz }
        end
      RUBY
    end

    it 'ignores variables return from block' do
      expect_no_offenses(<<-RUBY)
        it do
          $bar = 42
          baz = 123
          allow(Foo).to receive(:bar) { $bar }
          allow(Foo).to receive(:baz) { baz }
        end
      RUBY
    end

    it 'ignores array with dynamic values returned from block' do
      expect_no_offenses(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { [42, baz] }
        end
      RUBY
    end

    it 'ignores hash with dynamic values returned from block' do
      expect_no_offenses(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { {a: 42, b: baz} }
        end
      RUBY
    end

    it 'ignores block returning string with interpolation' do
      expect_no_offenses(<<-RUBY)
        it do
          bar = 42
          allow(Foo).to receive(:bar) { "You called \#{bar}" }
        end
      RUBY
    end

    it 'finds concatenated strings with no variables' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) do
                                      ^^ Use `and_return` for static values.
            "You called" \
            "me"
          end
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return("You called" \
            "me")
        end
      RUBY
    end

    it 'ignores stubs without return value' do
      expect_no_offenses(<<-RUBY)
        it do
          allow(Foo).to receive(:bar)
        end
      RUBY
    end

    it 'handles stubs in a method' do
      expect_no_offenses(<<-RUBY)
        def stub_foo
          allow(Foo).to receive(:bar)
        end
      RUBY
    end
  end

  context 'with EnforcedStyle `block`' do
    let(:enforced_style) { 'block' }

    it 'finds static values returned from method' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return(42)
                                      ^^^^^^^^^^ Use block for static values.
        end
      RUBY
    end

    it 'finds static values returned from chained method' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).with(1).and_return(42)
                                              ^^^^^^^^^^ Use block for static values.
        end
      RUBY
    end

    it 'ignores dynamic values returned from method' do
      expect_no_offenses(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return(baz)
        end
      RUBY
    end

    it 'ignores string with interpolation returned from method' do
      expect_no_offenses(<<-RUBY)
        it do
          bar = 42
          allow(Foo).to receive(:bar).and_return("You called \#{bar}")
        end
      RUBY
    end

    it 'ignores multiple values being returned from method' do
      expect_no_offenses(<<-RUBY)
        it do
          allow(Foo).to receive(:bar).and_return(42, 43, 44)
        end
      RUBY
    end

    it 'finds hash with only static values returned from method' do
      expect_offense(<<-RUBY)
        allow(Foo).to receive(:bar).and_return({ foo: 42 })
                                    ^^^^^^^^^^ Use block for static values.
        allow(Foo).to receive(:bar).and_return(foo: 42)
                                    ^^^^^^^^^^ Use block for static values.
        allow(Foo).to receive(:bar).and_return(
                                    ^^^^^^^^^^ Use block for static values.
          a: 42,
          b: 43
        )
      RUBY

      expect_correction(<<-RUBY) # Not perfect, but good enough.
        allow(Foo).to receive(:bar) { { foo: 42 } }
        allow(Foo).to receive(:bar) { { foo: 42 } }
        allow(Foo).to receive(:bar) { { a: 42,
          b: 43 } }
      RUBY
    end

    it 'finds nil returned from method' do
      expect_offense(<<-RUBY)
        allow(Foo).to receive(:bar).and_return(nil)
                                    ^^^^^^^^^^ Use block for static values.
      RUBY

      expect_correction(<<-RUBY)
        allow(Foo).to receive(:bar) { nil }
      RUBY
    end

    it 'finds concatenated strings with no variables' do
      expect_offense(<<-RUBY)
        allow(Foo).to receive(:bar).and_return('You called ' \\
                                    ^^^^^^^^^^ Use block for static values.
          'me')
      RUBY

      expect_correction(<<-RUBY)
        allow(Foo).to receive(:bar) { 'You called ' \\
          'me' }
      RUBY
    end
  end
end
