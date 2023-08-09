# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ReceiveMessages, :config do
  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3, 4].
        allow(Service).to receive(:bar).and_return(true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2, 4].
        allow(Service).to receive(:baz).and_return("foo")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2, 3].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive_messages(foo: baz, bar: true, baz: "foo")
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object and `receive(:foo=)`' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3].
        allow(Service).to receive(:foo=).and_return(true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive_messages(foo: baz, 'foo=': true)
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object and symbol methods' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:`).and_return(true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3].
        allow(Service).to receive(:[]).and_return(true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive_messages('`': true, '[]': true)
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object and return array' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return([1, 2])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3].
        allow(Service).to receive(:bar).and_return(3)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive_messages(foo: [1, 2], bar: 3)
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object and return hash' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return({ a: 1, b: 2 })
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3, 4].
        allow(Service).to receive(:bar).and_return("baz" => qux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2, 4].
        allow(Service).to receive(:baz).and_return(3)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2, 3].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive_messages(foo: { a: 1, b: 2 }, bar: { "baz" => qux }, baz: 3)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and return heredoc' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(<<~SQL)
          SELECT * FROM users;
        SQL
        allow(Service).to receive(:bar).and_return(3)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and receive counts' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(1).once
        allow(Service).to receive(:bar).and_return(2).twice
        allow(Service).to receive(:baz).and_return(3).exactly(3).times
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and return with splat' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(*array)
        allow(Service).to receive(:bar).and_return(*array)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and return multiple' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(1, 2)
        allow(Service).to receive(:bar).and_return(3, 4)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and message order' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(1).ordered
        allow(Service).to receive(:bar).and_return(2).ordered
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same local variable' do
    expect_offense(<<~RUBY)
      before do
        allow(user).to receive(:foo).and_return(baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3].
        allow(user).to receive(:bar).and_return(qux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(user).to receive_messages(foo: baz, bar: qux)
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object and another methods called between stubs' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(1)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [5].
        calling_some_method
        calling_another_method
        allow(Service).to receive(:bar).and_return(2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [2].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive_messages(foo: 1, bar: 2)
        calling_some_method
        calling_another_method
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and using multiple `.and_return` arguments' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(1, 2)
        allow(Service).to receive(:bar).and_return(3)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and using `.and_call_original`' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_call_original
        allow(Service).to receive(:bar).and_return(qux)
        allow(Service).to receive(:baz).and_call_original
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'different object`' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Foo).to receive(:foo).and_return(baz)
        allow(Bar).to receive(:bar).and_return(bar)
        allow(Baz).to receive(:baz).and_return(foo)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and same message`' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Foo).to receive(:foo).and_return(bar)
        allow(Foo).to receive(:foo).and_return(baz)
        allow(Foo).to receive(:bar).and_return(qux)
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object with block`' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo) { baz }
        allow(Service).to receive(:bar) { bar }
      end
    RUBY
  end

  it 'does not register an offense when multiple messeages stubbed on the ' \
     'same object and `.with` method`' do
    expect_no_offenses(<<~RUBY)
      before do
        allow(Service).to receive(:foo).with(1).and_return(baz)
        allow(Service).to receive(:bar).with(2).and_return(bar)
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'same object and different message' do
    expect_offense(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(bar)
        allow(Service).to receive(:bar).and_return(qux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [5].
        allow(Service).to receive(:foo).and_return(qux)
        allow(Service).to receive(:baz).and_return(qux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3].
      end
    RUBY

    expect_correction(<<~RUBY)
      before do
        allow(Service).to receive(:foo).and_return(bar)
        allow(Service).to receive_messages(bar: qux, baz: qux)
        allow(Service).to receive(:foo).and_return(qux)
      end
    RUBY
  end

  it 'registers an offense when multiple messeages stubbed on the ' \
     'different object and same message' do
    expect_offense(<<~RUBY)
      RSpec.describe do
        before do
          allow(X).to receive(:foo).and_return(1)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [4].
          allow(X).to receive(:bar).and_return(2)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `receive_messages` instead of multiple stubs on lines [3].
          allow(Y).to receive(:foo).and_return(3)
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        before do
          allow(X).to receive_messages(foo: 1, bar: 2)
          allow(Y).to receive(:foo).and_return(3)
        end
      end
    RUBY
  end
end
