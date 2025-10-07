# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedExampleGroupDescription do
  it 'registers an offense for repeated describe descriptions' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 5.
        # example group
      end

      describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 1.
        # example group
      end
    RUBY
  end

  it 'registers an offense for repeated context descriptions' do
    expect_offense(<<~RUBY)
      context 'when awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        # example group
      end

      context 'when awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 1.
        # example group
      end
    RUBY
  end

  it 'registers an offense with right pointing to lines of code' do
    expect_offense(<<~RUBY)
      describe 'super feature' do
        context 'when some case' do
          # ...
        end

        context 'when awesome case' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 10, 14.
          # example group
        end

        context 'when awesome case' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 6, 14.
          # example group
        end

        context 'when awesome case' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 6, 10.
          # example group
        end
      end
    RUBY
  end

  it 'does not register offense for different block descriptions' do
    expect_no_offenses(<<~RUBY)
      describe 'doing x' do
        # example group
      end

      describe 'doing y' do
        # example group
      end
    RUBY
  end

  it 'does not register offense for describe block with additional docstring' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'Animal', 'dog' do
        # example group
      end

      RSpec.describe 'Animal', 'cat' do
        # example group
      end
    RUBY
  end

  it 'does not register offense for describe block with several docstring' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'Animal', 'dog', type: :request do
        # example group
      end

      RSpec.describe 'Animal', 'cat', type: :request do
        # example group
      end
    RUBY
  end

  it 'registers offense for different example group with ' \
     'similar descriptions' do
    expect_offense(<<~RUBY)
      describe 'Animal' do
      ^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 5.
        # example group
      end

      context 'Animal' do
      ^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 1.
        # example group
      end
    RUBY
  end

  it 'registers offense only for RSPEC namespace example groups' do
    expect_offense(<<~RUBY)
      helpers.describe 'doing x' do
        it { cool_predicate_method }
      end

      RSpec.describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 9.
        it { cool_predicate_method }
      end

      context 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers offense only for RSPEC namespace example groups in any order' do
    expect_offense(<<~RUBY)
      RSpec.describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 5.
        it { cool_predicate_method }
      end

      context 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 1.
        it { cool_predicate_method }
      end

      helpers.describe 'doing x' do
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers offense only for example group' do
    expect_offense(<<~RUBY)
      RSpec.describe 'A' do
        stub_all_http_calls()
        allowed_statuses = %i[open submitted approved].freeze
        before { create(:admin) }

        describe '#load' do
        ^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 10.
          it { cool_predicate_method }
        end

        describe '#load' do
        ^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 6.
          it { cool_predicate_method }
        end
      end
    RUBY
  end

  it 'considers interpolated docstrings as different descriptions' do
    expect_no_offenses(<<~RUBY)
      context "when class is \#{A::B}" do
        # ...
      end

      context "when class is \#{C::D}" do
        # ...
      end
    RUBY
  end

  it 'registers offense correctly for interpolated docstrings' do
    expect_offense(<<~RUBY)
      context "when class is \#{A::B}" do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        # ...
      end

      context "when class is \#{A::B}" do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 1.
        # ...
      end
    RUBY
  end

  it 'considers different classes as different descriptions' do
    expect_no_offenses(<<~RUBY)
      context A::B do
        # ...
      end

      context C::D do
        # ...
      end
    RUBY
  end

  it 'registers offense if same method used in docstring' do
    expect_offense(<<~RUBY)
      context(description) do
      ^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        # ...
      end

      context(description) do
      ^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 1.
        # ...
      end
    RUBY
  end

  it 'registers offense correctly if example groups are separated' do
    expect_offense(<<~RUBY)
      describe 'repeated' do
      ^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 7.
        it { is_expected.to be_truthy }
      end

      before { do_something }

      describe 'repeated' do
      ^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) 1.
        it { is_expected.to be_truthy }
      end
    RUBY
  end

  it 'does not register offense for example group without descriptions' do
    expect_no_offenses(<<~RUBY)
      context do
        # ...
      end

      context do
        # ...
      end
    RUBY
  end

  it 'does not register offense for non-repeating group examples with skip' do
    expect_no_offenses(<<~RUBY)
      describe 'Something' do
        context 'when foo is true' do
          skip
        end

        context 'when foo is false' do
          skip
        end
      end
    RUBY
  end

  it 'does not register offense for non-repeating group examples ' \
     'with pending' do
    expect_no_offenses(<<~RUBY)
      describe 'Something' do
        context 'when foo is true' do
          pending
        end

        context 'when foo is false' do
          pending
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with pending examples' do
    expect_offense(<<~RUBY)
      describe 'Screenshots::CreateInteractor' do
        context 'when the request is valid' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 6.
          pending 'add something'
        end

        context 'when the request is valid' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
          pending 'add something'
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with skip examples' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 6.
          skip 'not implemented'
        end

        context 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
          skip 'not implemented'
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with pending metadata' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo', :pending do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        end

        context 'when foo', :pending do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with skip metadata' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo', :skip do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        end

        context 'when foo', :skip do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with skip metadata hash' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo', skip: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        end

        context 'when foo', skip: true do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with pending metadata hash' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo', pending: 'not ready' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 5.
        end

        context 'when foo', pending: 'not ready' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
        end
      end
    RUBY
  end

  it 'registers offense with mixed pending and skip' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 6.
          pending 'add something'
        end

        context 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
          skip 'not ready'
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with xcontext' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        xcontext 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^^ Repeated xcontext block description on line(s) 5.
        end

        xcontext 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^^ Repeated xcontext block description on line(s) 2.
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions with xdescribe' do
    expect_offense(<<~RUBY)
      xdescribe 'Something' do
      ^^^^^^^^^^^^^^^^^^^^^^^^ Repeated xdescribe block description on line(s) 5.
        it { is_expected.to be_valid }
      end

      xdescribe 'Something' do
      ^^^^^^^^^^^^^^^^^^^^^^^^ Repeated xdescribe block description on line(s) 1.
        it { is_expected.to be_valid }
      end
    RUBY
  end

  it 'registers offense when one group has pending and other does not' do
    expect_offense(<<~RUBY)
      describe 'Something' do
        context 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 6.
          pending 'add something'
        end

        context 'when foo' do
        ^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) 2.
          it { is_expected.to be_valid }
        end
      end
    RUBY
  end
end
