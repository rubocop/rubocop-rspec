# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LetBeforeExamples do
  it 'flags `let` after `it`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it { is_expected.to be_after_let }
        let(:foo) { bar }
        ^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:foo) { bar }
        it { is_expected.to be_after_let }
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

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:foo) { bar }
        context 'a context' do
          it { is_expected.to be_after_let }
        end

      end
    RUBY
  end

  it 'flags `let` after `include_examples`, but does not autocorrect' do
    # NOTE: include_examples may define the same variable as `let`,
    # and changing the order may break the spec due to order dependency
    # if `let` is moved above.
    expect_offense(<<-RUBY)
      RSpec.describe User do
        include_examples('should be BEFORE let as it defines `let(:foo)`, too')

        let(:foo) { 'bar' }
        ^^^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY

    expect_no_corrections
  end

  it 'flags `let` after `it_behaves_like`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like('should be after let')

        let(:foo) { bar }
        ^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:foo) { bar }
        it_behaves_like('should be after let')

      end
    RUBY
  end

  it 'flags `let` with proc argument' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like('should be after let')

        let(:user, &args[:build_user])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:user, &args[:build_user])
        it_behaves_like('should be after let')

      end
    RUBY
  end

  it 'flags `let` with a heredoc argument' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like('should be after let')

        let(:foo) { (<<-SOURCE) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Move `let` before the examples in the group.
        some long text here
        SOURCE
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:foo) { (<<-SOURCE) }
        some long text here
        SOURCE
        it_behaves_like('should be after let')

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

        it_behaves_like('everything is fine')
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

        it_behaves_like('everything is fine')
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
        it_behaves_like 'special user' do
          let(:foo) { bar }
        end
      end
    RUBY
  end
end
