RSpec.describe RuboCop::Cop::RSpec::LetBeforeExamples do
  subject(:cop) { described_class.new }

  it 'flags `let` after `it`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it { is_expected.to be_after_let }
        let(:foo) { bar }
        ^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY
  end

  it 'flags `let` after `context`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        context 'a context' do
          it { is_expected.to be_after_let }
        end

        let(:foo) { bar }
        ^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY
  end

  it 'flags `let` after `include_examples`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        include_examples('should be after let')

        let(:foo) { bar }
        ^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY
  end

  it 'does not flag `let` before the examples' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:foo) { bar }

        it { is_expected.to be_after_let }

        context 'a context' do
          it { is_expected.to work }
        end

        include_examples('everything is fine')
      end
    RUBY
  end

  it 'does not flag `let` in a nested context' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:foo) { bar }

        context 'something else' do
          let(:foo) { baz }
          it { is_expected.to work }
        end

        include_examples('everything is fine')
      end
    RUBY
  end

  it 'allows inclusion of context before `let`' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        include_context 'special user'

        let(:foo) { bar }
      end
    RUBY
  end

  it 'ignores single-line example blocks' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        include_examples 'special user' do
          let(:foo) { bar }
        end
      end
    RUBY
  end

  it 'does not encounter an error when handling an empty describe' do
    expect { inspect_source('RSpec.describe(User) do end', 'a_spec.rb') }
      .not_to raise_error
  end
end
