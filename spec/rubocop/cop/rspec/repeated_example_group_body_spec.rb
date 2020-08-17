# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedExampleGroupBody do
  it 'registers an offense for repeated describe body' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [5]
        it { cool_predicate_method }
      end

      describe 'doing y' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [1]
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers an offense for repeated context body' do
    expect_offense(<<-RUBY)
      context 'when awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [5]
        it { cool_predicate_method }
      end

      context 'when another awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [1]
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers an offense for several repeated context body' do
    expect_offense(<<-RUBY)
      context 'when usual case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [5, 9]
        it { cool_predicate_method }
      end

      context 'when awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [1, 9]
        it { cool_predicate_method }
      end

      context 'when another awesome case' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [1, 5]
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'does not register offense for different block body implementation' do
    expect_no_offenses(<<-RUBY)
      context 'when awesome case' do
        it { cool_predicate_method }
      end

      context 'when another awesome case' do
        it { another_predicate_method }
      end
    RUBY
  end

  it 'does not register offense if metadata is different' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it { cool_predicate_method }
      end

      describe 'doing x', :request do
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'does not register offense if module arg is different' do
    expect_no_offenses(<<-RUBY)
      describe CSV::Row do
        it { is_expected.to respond_to :headers }
      end

      describe CSV::Table do
        it { is_expected.to respond_to :headers }
      end
    RUBY
  end

  it 'does not register offense when module arg namespace is different' do
    expect_no_offenses(<<-RUBY)
      describe CSV::Parser do
        it { expect(described_class).to respond_to(:parse) }
      end

      describe URI::Parser do
        it { expect(described_class).to respond_to(:parse) }
      end
    RUBY
  end

  it 'registers an offense for when module arg and namespace are identical' do
    expect_offense(<<-RUBY)
      context Net::HTTP do
      ^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [5]
        it { expect(described_class).to respond_to :start }
      end

      context Net::HTTP do
      ^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [1]
        it { expect(described_class).to respond_to :start }
      end
    RUBY
  end

  it 'does not register offense with several docstring' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x', :json, 'request' do
        it { cool_predicate_method }
      end

      describe 'doing x', 'request' do
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers offense for different groups' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [5]
        it { cool_predicate_method }
      end

      context 'when a is true' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [1]
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'does not register offense for example groups in different groups' do
    expect_no_offenses(<<-RUBY)
      describe 'A' do
        describe '.b' do
          context 'when this' do
            it { do_something }
          end
        end
        context 'when this' do
          it { do_something }
        end
      end
    RUBY
  end

  it 'registers offense only for RSPEC namespace example groups' do
    expect_offense(<<-RUBY)
      helpers.describe 'doing x' do
        it { cool_predicate_method }
      end

      RSpec.describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [9]
        it { cool_predicate_method }
      end

      context 'when a is true' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [5]
        it { cool_predicate_method }
      end
    RUBY
  end

  it 'registers offense only for RSPEC namespace example groups in any order' do
    expect_offense(<<-RUBY)
      RSpec.describe 'doing x' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [5]
        it { cool_predicate_method }
      end

      context 'when a is true' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated context block body on line(s) [1]
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
        allowed_statuses = %i[open submitted approved].freeze

        describe '#load' do
        ^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [11]
          it { cool_predicate_method }
        end

        describe '#load' do
        ^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [7]
          it { cool_predicate_method }
        end
      end
    RUBY
  end

  it 'skips `skip` and `pending` statements' do
    expect_no_offenses(<<-RUBY)
      context 'rejected' do
        skip
      end

      context 'processed' do
        skip
      end

      context 'processed' do
        pending
      end
    RUBY
  end

  it 'registers offense correctly if example groups are separated' do
    expect_offense(<<-RUBY)
      describe 'repeated' do
      ^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [7]
        it { is_expected.to be_truthy }
      end

      before { do_something }

      describe 'this is repeated' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Repeated describe block body on line(s) [1]
        it { is_expected.to be_truthy }
      end
    RUBY
  end

  it 'does not register offense for same examples with different data' do
    expect_no_offenses(<<-RUBY)
      context 'when admin' do
        let(:user) { admin }
        it { is_expected.to be_truthy }
      end

      context 'when regular user' do
        let(:user) { staff }
        it { is_expected.to be_truthy }
      end
    RUBY
  end

  it 'does not register offense if no descriptions, but different body' do
    expect_no_offenses(<<-RUBY)
      context do
        let(:preferences) { default_preferences }

        it { is_expected.to eq false }
      end

      context do
        let(:preferences) { %w[a] }

        it { is_expected.to eq true }
      end
    RUBY
  end

  it 'registers offense no descriptions and similar body' do
    expect_offense(<<-RUBY)
      context do
      ^^^^^^^^^^ Repeated context block body on line(s) [7]
        let(:preferences) { %w[a] }

        it { is_expected.to eq true }
      end

      context do
      ^^^^^^^^^^ Repeated context block body on line(s) [1]
        let(:preferences) { %w[a] }

        it { is_expected.to eq true }
      end
    RUBY
  end
end
