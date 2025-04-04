# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ChangeWithoutExpect, :config do
  it 'registers an offense for a `change` call with only `by` ' \
     'without an `expect` block' do
    expect_offense(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).by(1)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `change` matcher within an `expect` block.
      end
    RUBY
  end

  it 'registers an offense for a `change` call with only `by_at_least` ' \
     'without an `expect` block' do
    expect_offense(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).by_at_least(1)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `change` matcher within an `expect` block.
      end
    RUBY
  end

  it 'registers an offense for a `change` call with only `by_at_most` ' \
     'without an `expect` block' do
    expect_offense(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).by_at_most(1)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `change` matcher within an `expect` block.
      end
    RUBY
  end

  it 'registers an offense for a `change` call with only `from` ' \
     'without an `expect` block' do
    expect_offense(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).from(0)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `change` matcher within an `expect` block.
      end
    RUBY
  end

  it 'registers an offense for a `change` call with exactly `from().to()` ' \
     'without an `expect` block' do
    expect_offense(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).from(0).to(1)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `change` matcher within an `expect` block.
      end
    RUBY
  end

  it 'does not register an offense for a `change` call with `from().by()` ' \
     'without an `expect` block' do
    expect_no_offenses(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).from(0).by(1)
      end
    RUBY
  end

  it 'does not register an offense for a simple `change` call ' \
     'without chains' do
    expect_no_offenses(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count)
      end
    RUBY
  end

  it 'does not register an offense for a `change` call with unsupported ' \
     'chain method' do
    expect_no_offenses(<<~RUBY)
      it 'changes the count' do
        change(Counter, :count).some_other_method(123)
      end
    RUBY
  end

  it 'does not register an offense for `change` with chains within an ' \
     '`expect` block' do
    expect_no_offenses(<<~RUBY)
      it 'changes the count' do
        expect { subject }.to change(Counter, :count).by(1)
      end
    RUBY
  end

  it 'does not register an offense for `change` with from-to chain ' \
     'within an `expect` block' do
    expect_no_offenses(<<~RUBY)
      it 'changes the count' do
        expect { subject }.to change(Counter, :count).from(0).to(1)
      end
    RUBY
  end

  it 'does not register an offense for `change` with chains ' \
     'within an `expect` with not_to' do
    expect_no_offenses(<<~RUBY)
      it 'does not change the count' do
        expect { subject }.not_to change(Counter, :count).by(1)
      end
    RUBY
  end
end
