# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DiscardedMatcher do
  it 'registers an offense for standalone `change` with block in example' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to \\
          change { obj.foo }.from(1).to(2)
          change { obj.bar }.from(3).to(4)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for standalone `change` with arguments' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change(Foo, :bar).by(1)
        change(Foo, :baz).by(2)
        ^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for standalone `change` block without chain' do
    expect_offense(<<~RUBY)
      specify do
        change { obj.bar }
        ^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for standalone `change` in a one-liner example' do
    expect_offense(<<~RUBY)
      specify { change { obj.bar }.from(1).to(2) }
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
    RUBY
  end

  it 'registers an offense for standalone `receive`' do
    expect_offense(<<~RUBY)
      specify do
        expect(foo).to receive(:bar)
        receive(:baz).and_return(1)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `receive` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for standalone `receive_messages`' do
    expect_offense(<<~RUBY)
      specify do
        receive_messages(foo: 1, bar: 2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `receive_messages` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for standalone `receive_message_chain`' do
    expect_offense(<<~RUBY)
      specify do
        expect(foo).to receive(:bar)
        receive_message_chain(:baz, :qux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `receive_message_chain` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'does not register an offense when `change` is used with `expect`' do
    expect_no_offenses(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
      end
    RUBY
  end

  it 'does not register an offense when `change` is chained with `.and`' do
    expect_no_offenses(<<~RUBY)
      specify do
        expect { result }.to \\
          change { obj.foo }.from(1).to(2)
          .and change { obj.bar }.from(3).to(4)
      end
    RUBY
  end

  it 'does not register an offense when `receive` is used with `allow`' do
    expect_no_offenses(<<~RUBY)
      specify do
        allow(foo).to receive(:bar).and_return(1)
      end
    RUBY
  end

  it 'does not register an offense when `receive` is used with `expect`' do
    expect_no_offenses(<<~RUBY)
      specify do
        expect(foo).to receive(:bar)
      end
    RUBY
  end

  it 'does not register an offense for `change` at end of non-example block' do
    expect_no_offenses(<<~RUBY)
      specify do
        [1, 2, 3].each do |n|
          change { obj.foo }.from(n).to(n + 1)
        end
      end
    RUBY
  end

  it 'does not register an offense outside of example context' do
    expect_no_offenses(<<~RUBY)
      change { obj.bar }
    RUBY
  end

  it 'does not register an offense for multiple matchers outside example' do
    expect_no_offenses(<<~RUBY)
      change { obj.foo }
      change { obj.bar }
    RUBY
  end

  it 'does not register an offense for multiple matchers with args outside' do
    expect_no_offenses(<<~RUBY)
      change(Foo, :foo)
      change(Foo, :bar)
    RUBY
  end

  it 'registers an offense for `change` in modifier `if`' do
    expect_offense(<<~RUBY)
      specify do
        change { obj.bar } if condition
        ^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for `change` in modifier `unless`' do
    expect_offense(<<~RUBY)
      specify do
        change { obj.bar } unless condition
        ^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for `change` in both `if` and `else` branches' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
        if condition
          change { obj.bar }.from(3).to(4)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
        else
          change { obj.baz }.from(5).to(6)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
        end
      end
    RUBY
  end

  it 'does not register an offense for `change` used as `if` condition' do
    expect_no_offenses(<<~RUBY)
      specify do
        if change { obj.foo }.from(1).to(2)
          something
        end
      end
    RUBY
  end

  it 'does not register an offense for `change` in non-void `if` branch' do
    expect_no_offenses(<<~RUBY)
      specify do
        result = if condition
                   change { obj.foo }.from(1).to(2)
                 end
      end
    RUBY
  end

  it 'registers an offense for `change` in a ternary branch' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
        condition ? change { obj.bar } : nil
                    ^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for `change` in a `when` branch' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
        case condition
        when :update then change { obj.bar }.from(3).to(4)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
        end
      end
    RUBY
  end

  it 'registers an offense for `change` in a `case` else branch' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
        case condition
        when :update then expect { result }.to change { obj.bar }.from(3).to(4)
        else change { obj.baz }.from(5).to(6)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
        end
      end
    RUBY
  end

  it 'does not register an offense for `change` in `when` with `expect`' do
    expect_no_offenses(<<~RUBY)
      specify do
        case condition
        when :update then expect { result }.to change { obj.bar }.from(3).to(4)
        end
      end
    RUBY
  end

  it 'does not register an offense for `change` used as `when` condition' do
    expect_no_offenses(<<~RUBY)
      specify do
        case condition
        when change { obj.foo }.from(1).to(2) then something
        end
      end
    RUBY
  end

  it 'does not register an offense for `change` in non-void `when` branch' do
    expect_no_offenses(<<~RUBY)
      specify do
        result = case condition
                 when :update then change { obj.baz }.from(5).to(6)
                 end
      end
    RUBY
  end

  it 'does not register an offense for `change` in non-void `case` else' do
    expect_no_offenses(<<~RUBY)
      specify do
        result = case condition
                 when :update then something
                 else change { obj.baz }.from(5).to(6)
                 end
      end
    RUBY
  end

  it 'does not register an offense for `change` used as `case` condition' do
    expect_no_offenses(<<~RUBY)
      specify do
        case change { obj.foo }.from(1).to(2)
        when 1 then something
        end
      end
    RUBY
  end

  it 'registers an offense for `change` on the right side of `&&`' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
        change { obj.bar }.from(3).to(4) && change { obj.baz }.from(5).to(6)
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'registers an offense for `change` on the right side of `||`' do
    expect_offense(<<~RUBY)
      specify do
        expect { result }.to change { obj.foo }.from(1).to(2)
        change { obj.bar }.from(3).to(4) || change { obj.baz }.from(5).to(6)
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The result of `change` is not used. Did you mean to chain it with `.and`?
      end
    RUBY
  end

  it 'does not register an offense for `change` on rhs of non-void `&&`' do
    expect_no_offenses(<<~RUBY)
      specify do
        result = change { obj.foo }.from(1).to(2) && change { obj.bar }.from(3).to(4)
      end
    RUBY
  end

  it 'does not register an offense for `change` used with `&` operator' do
    expect_no_offenses(<<~RUBY)
      specify do
        expect { result }.to \\
          change { obj.foo }.from(1).to(2) &
          change { obj.bar }.from(3).to(4)
      end
    RUBY
  end

  it 'does not register an offense for `change` as a method argument' do
    expect_no_offenses(<<~RUBY)
      specify do
        foo(change { obj.foo }.from(1).to(2))
      end
    RUBY
  end

  it 'does not register an offense when `change` is called on a receiver' do
    expect_no_offenses(<<~RUBY)
      specify do
        foo.change { obj.foo }
      end
    RUBY
  end
end
