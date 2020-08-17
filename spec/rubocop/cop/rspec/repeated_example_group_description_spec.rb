# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedExampleGroupDescription do
  it 'registers an offense for repeated describe descriptions' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [5]
        # example group
      end

      describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [1]
        # example group
      end
    RUBY
  end

  it 'registers an offense for repeated context descriptions' do
    expect_offense(<<-RUBY)
      context 'when awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [5]
        # example group
      end

      context 'when awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [1]
        # example group
      end
    RUBY
  end

  it 'registers an offense with right pointing to lines of code' do
    expect_offense(<<-RUBY)
      describe 'super feature' do
        context 'when some case' do
          # ...
        end

        context 'when awesome case' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [10, 14]
          # example group
        end

        context 'when awesome case' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [6, 14]
          # example group
        end

        context 'when awesome case' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [6, 10]
          # example group
        end
      end
    RUBY
  end

  it 'does not register offense for different block descriptions' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        # example group
      end

      describe 'doing y' do
        # example group
      end
    RUBY
  end

  it 'does not register offense for describe block with additional docstring' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe 'Animal', 'dog' do
        # example group
      end

      RSpec.describe 'Animal', 'cat' do
        # example group
      end
    RUBY
  end

  it 'does not register offense for describe block with several docstring' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe 'Animal', 'dog', type: :request do
        # example group
      end

      RSpec.describe 'Animal', 'cat', type: :request do
        # example group
      end
    RUBY
  end

  it 'register offense for different example group with similar descriptions' do
    expect_offense(<<-RUBY)
      describe 'Animal' do
      ^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [5]
        # example group
      end

      context 'Animal' do
      ^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [1]
        # example group
      end
    RUBY
  end

  it 'registers offense only for RSPEC namespace example groups' do
    expect_offense(<<-RUBY)
      helpers.describe 'doing x' do
        it { cool_predicate_method }
      end

      RSpec.describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [9]
        it { cool_predicate_method }
      end

      context 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [5]
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers offense only for RSPEC namespace example groups in any order' do
    expect_offense(<<-RUBY)
      RSpec.describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [5]
        it { cool_predicate_method }
      end

      context 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [1]
        it { cool_predicate_method }
      end

      helpers.describe 'doing x' do
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers offense only for example group' do
    expect_offense(<<-RUBY)
      RSpec.describe 'A' do
        stub_all_http_calls()
        allowed_statuses = %i[open submitted approved].freeze
        before { create(:admin) }

        describe '#load' do
        ^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [10]
          it { cool_predicate_method }
        end

        describe '#load' do
        ^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [6]
          it { cool_predicate_method }
        end
      end
    RUBY
  end

  it 'considers interpolated docstrings as different descriptions' do
    expect_no_offenses(<<-RUBY)
      context "when class is \#{A::B}" do
        # ...
      end

      context "when class is \#{C::D}" do
        # ...
      end
    RUBY
  end

  it 'registers offense correctly for interpolated docstrings' do
    expect_offense(<<-RUBY)
      context "when class is \#{A::B}" do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [5]
        # ...
      end

      context "when class is \#{A::B}" do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [1]
        # ...
      end
    RUBY
  end

  it 'considers different classes as different descriptions' do
    expect_no_offenses(<<-RUBY)
      context A::B do
        # ...
      end

      context C::D do
        # ...
      end
    RUBY
  end

  it 'register offense if same method used in docstring' do
    expect_offense(<<-RUBY)
      context(description) do
      ^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [5]
        # ...
      end

      context(description) do
      ^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block description on line(s) [1]
        # ...
      end
    RUBY
  end

  it 'registers offense correctly if example groups are separated' do
    expect_offense(<<-RUBY)
      describe 'repeated' do
      ^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [7]
        it { is_expected.to be_truthy }
      end

      before { do_something }

      describe 'repeated' do
      ^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block description on line(s) [1]
        it { is_expected.to be_truthy }
      end
    RUBY
  end

  it 'does not register offense for example group without descriptions' do
    expect_no_offenses(<<-RUBY)
      context do
        # ...
      end

      context do
        # ...
      end
    RUBY
  end
end
