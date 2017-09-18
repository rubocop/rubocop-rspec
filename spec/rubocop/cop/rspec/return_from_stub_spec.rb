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
                        ^^^^^^^^^^^^^ Use `and_return` for static values.
        end
      RUBY
    end

    it 'finds array with only static values returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { [42, 43] }
                        ^^^^^^^^^^^^^ Use `and_return` for static values.
        end
      RUBY
    end

    it 'finds hash with only static values returned from block' do
      expect_offense(<<-RUBY)
        it do
          allow(Foo).to receive(:bar) { {a: 42, b: 43} }
                        ^^^^^^^^^^^^^ Use `and_return` for static values.
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
                        ^^^^^^^^^^^^^ Use `and_return` for static values.
            "You called" \
            "me"
          end
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
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use block for static values.
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
  end
end
