# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ReceiveNever do
  it 'registers an offense for expect(...).to receive(...).never' do
    expect_offense(<<~RUBY)
      expect(foo).to receive(:bar).never
                                   ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).not_to receive(:bar)
    RUBY
  end

  it 'registers an offense with multiple method calls' do
    expect_offense(<<~RUBY)
      expect(foo).to receive(:bar).with(1).never
                                           ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).not_to receive(:bar).with(1)
    RUBY
  end

  it 'does not register an offense for allow(...).to receive(...).never' do
    expect_no_offenses(<<~RUBY)
      allow(foo).to receive(:bar).never
    RUBY
  end

  it 'does not register an offense for ' \
     'allow(...).to receive(...).with(...).never' do
    expect_no_offenses(<<~RUBY)
      allow(foo).to receive(:bar).with(1).never
    RUBY
  end

  it 'registers an offense for expect with RSpec prefix' do
    expect_offense(<<~RUBY)
      RSpec.expect(foo).to receive(:bar).never
                                         ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      RSpec.expect(foo).not_to receive(:bar)
    RUBY
  end

  it 'does not register an offense for allow with RSpec prefix' do
    expect_no_offenses(<<~RUBY)
      RSpec.allow(foo).to receive(:bar).never
    RUBY
  end

  it 'registers an offense for expect_any_instance_of' do
    expect_offense(<<~RUBY)
      expect_any_instance_of(Foo).to receive(:bar).never
                                                   ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      expect_any_instance_of(Foo).not_to receive(:bar)
    RUBY
  end

  it 'does not register an offense for allow_any_instance_of' do
    expect_no_offenses(<<~RUBY)
      allow_any_instance_of(Foo).to receive(:bar).never
    RUBY
  end

  it 'registers an offense for is_expected' do
    expect_offense(<<~RUBY)
      is_expected.to receive(:bar).never
                                   ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      is_expected.not_to receive(:bar)
    RUBY
  end

  it 'registers an offense with complex expect block' do
    expect_offense(<<~RUBY)
      expect { foo }.to receive(:bar).never
                                      ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      expect { foo }.not_to receive(:bar)
    RUBY
  end

  it 'does not register an offense for allow with complex block' do
    expect_no_offenses(<<~RUBY)
      allow { foo }.to receive(:bar).never
    RUBY
  end

  it 'does not register an offense for expect(...).not_to receive(...)' do
    expect_no_offenses(<<~RUBY)
      expect(foo).not_to receive(:bar)
    RUBY
  end

  it 'does not register an offense when never is used without receive' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to never_call_this_method
    RUBY
  end

  it 'registers an offense for multiline expect' do
    expect_offense(<<~RUBY)
      expect(foo)
        .to receive(:bar)
        .never
         ^^^^^ Use `not_to receive` instead of `never`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo)
        .not_to receive(:bar)
      #{'  '}
    RUBY
  end

  it 'does not register an offense for multiline allow' do
    expect_no_offenses(<<~RUBY)
      allow(foo)
        .to receive(:bar)
        .never
    RUBY
  end

  it 'handles nested expectations correctly' do
    expect_offense(<<~RUBY)
      expect(foo).to receive(:bar) do
        expect(baz).to receive(:qux).never
                                     ^^^^^ Use `not_to receive` instead of `never`.
      end
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to receive(:bar) do
        expect(baz).not_to receive(:qux)
      end
    RUBY
  end

  it 'does not flag allow in nested context when outer is expect' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to receive(:bar) do
        allow(baz).to receive(:qux).never
      end
    RUBY
  end

  it 'does not register an offense when .never is used without receive' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to something.never
    RUBY
  end

  it 'does not register an offense when .never is used on a non-stub method' do
    expect_no_offenses(<<~RUBY)
      expect(foo.bar).to be.never
    RUBY
  end

  it 'does not register an offense when .never is called directly without ' \
     'receive chain' do
    expect_no_offenses(<<~RUBY)
      foo.never
    RUBY
  end

  it 'does not register an offense when receive is present but never is ' \
     'on a different chain' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to receive(:bar)
      something.never
    RUBY
  end
end
