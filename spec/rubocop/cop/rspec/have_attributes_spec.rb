# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::HaveAttributes do
  it 'registers an offense for multiple expectations on the same object' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to eq(bar)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.fu).to eq(bax)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.name).to eq(baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(obj).to have_attributes(
        foo: bar,
          fu: bax,
          name: baz
      )
      end
    RUBY
  end

  it 'does not register an offense for single expectation' do
    expect_no_offenses(<<~RUBY)
      it 'checks attribute' do
        expect(obj.foo).to eq(bar)
      end
    RUBY
  end

  it 'does not register an offense when there is no method receiver' do
    expect_no_offenses(<<~RUBY)
      it 'checks method calls' do
        expect(foo).to eq(bar)
        expect(baz).to eq(bar)
      end
    RUBY
  end

  it 'does not register an offense for expectations on different objects' do
    expect_no_offenses(<<~RUBY)
      it 'checks different objects' do
        expect(obj1.foo).to eq(bar)
        expect(obj2.fu).to eq(bax)
      end
    RUBY
  end

  it 'does not register an offense for method chains' do
    expect_no_offenses(<<~RUBY)
      it 'checks method chain' do
        expect(obj.foo.bar).to eq(baz)
        expect(obj.fu.bax).to eq(qux)
      end
    RUBY
  end

  it 'does not register an offense for method calls with arguments' do
    expect_no_offenses(<<~RUBY)
      it 'checks method with args' do
        expect(obj.foo(1)).to eq(bar)
        expect(obj.fu(2)).to eq(bax)
      end
    RUBY
  end

  it 'does not register an offense when only a single matcher is supported' do
    expect_no_offenses(<<~RUBY)
      it 'checks with other matchers' do
        expect(obj.foo).to be(bar)
        expect(obj.fu).to include(bax)
      end
    RUBY
  end

  it 'does not register an offense for not_to expectations' do
    expect_no_offenses(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).not_to eq(bar)
        expect(obj.fu).not_to eq(bax)
      end
    RUBY
  end

  it 'does not register an offense for mixed to and not_to expectations' do
    expect_no_offenses(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to eq(bar)
        expect(obj.fu).not_to eq(bax)
      end
    RUBY
  end

  it 'handles different value types' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to eq('bar')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.num).to eq(42)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.flag).to eq(true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(obj).to have_attributes(
        foo: 'bar',
          num: 42,
          flag: true
      )
      end
    RUBY
  end

  it 'handles multiple offending objects' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to eq(bar)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj2.foo).to eq(bar)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.fu).to eq(bax)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj2.fu).to eq(bax)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(obj).to have_attributes(
        foo: bar,
          fu: bax
      )
        expect(obj2).to have_attributes(
        foo: bar,
          fu: bax
      )
      end
    RUBY
  end

  it 'preserves other code between expectations' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to eq(bar)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        some_helper_method
        expect(obj.fu).to eq(bax)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        another_statement
        expect(obj.name).to eq(baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(obj).to have_attributes(
        foo: bar,
          fu: bax,
          name: baz
      )
        some_helper_method
        another_statement
      end
    RUBY
  end

  it 'ignores unsupported matchers' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to eq(bar)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.fu).to eq(bax)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.name).to be(baz)
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(obj).to have_attributes(
        foo: bar,
          fu: bax
      )
        expect(obj.name).to be(baz)
      end
    RUBY
  end

  it 'transforms mixed matchers' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(obj.foo).to start_with(bar)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.name).to contain_exactly(baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.type).to be_an_instance_of(String)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.value).to be_within(0.1)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.suffix).to end_with(qux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(obj.status).to eq(200)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(obj).to have_attributes(
        foo: a_string_starting_with(bar),
          name: a_collection_containing_exactly(baz),
          type: an_instance_of(String),
          value: a_value_within(0.1),
          suffix: a_string_ending_with(qux),
          status: 200
      )
      end
    RUBY
  end

  it 'wraps keyword arguments in braces' do
    expect_offense(<<~RUBY)
      it 'checks attributes' do
        expect(error.sentry_context).to eq(extra: { http_status_code: response_status, http_body: response_body })
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
        expect(error.status).to eq(200)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine multiple expectations on the same object using `have_attributes`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'checks attributes' do
        expect(error).to have_attributes(
        sentry_context: { extra: { http_status_code: response_status, http_body: response_body } },
          status: 200
      )
      end
    RUBY
  end
end
