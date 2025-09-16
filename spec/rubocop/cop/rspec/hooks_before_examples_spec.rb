# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::HooksBeforeExamples do
  it 'flags `before` after `it`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        it { is_expected.to be_after_before_hook }
        before { setup }
        ^^^^^^^^^^^^^^^^ Move `before` above the examples in the group.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        before { setup }
        it { is_expected.to be_after_before_hook }
      end
    RUBY
  end

  it 'flags `before` after `context`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        context 'a context' do
          it { is_expected.to be_after_before_hook }
        end

        before { setup }
        ^^^^^^^^^^^^^^^^ Move `before` above the examples in the group.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        before { setup }
        context 'a context' do
          it { is_expected.to be_after_before_hook }
        end

      end
    RUBY
  end

  it 'flags `before` after `include_examples`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        include_examples('should be after before-hook')

        before { setup }
        ^^^^^^^^^^^^^^^^ Move `before` above the examples in the group.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        before { setup }
        include_examples('should be after before-hook')

      end
    RUBY
  end

  it 'flags `after` after an example' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        it { is_expected.to be_after_after_hook }
        after { cleanup }
        ^^^^^^^^^^^^^^^^^ Move `after` above the examples in the group.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        after { cleanup }
        it { is_expected.to be_after_after_hook }
      end
    RUBY
  end

  it 'flags scoped hook after an example' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        it { is_expected.to be_after_before_hook }
        before(:each) { cleanup }
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Move `before` above the examples in the group.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        before(:each) { cleanup }
        it { is_expected.to be_after_before_hook }
      end
    RUBY
  end

  it 'works with comments' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        it { is_expected.to be_after_before_hook } # h
        # setup the system
        # with multiline comment
        before { setup } # some setup
        ^^^^^^^^^^^^^^^^ Move `before` above the examples in the group.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        # setup the system
        # with multiline comment
        before { setup } # some setup
        it { is_expected.to be_after_before_hook } # h
      end
    RUBY
  end

  it 'does not flag hooks before the examples' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        before(:each) { setup }
        after(:each) { cleanup }

        it { is_expected.to be_after_hooks }

        context 'a context' do
          it { is_expected.to work }
        end

        include_examples('everything is fine')
      end
    RUBY
  end

  it 'does not flag `before` in a nested context' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        before { setup }

        context 'something else' do
          before { additional_setup }
          it { is_expected.to work }
        end

        include_examples('everything is fine')
      end
    RUBY
  end

  it 'allows inclusion of context before hooks' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        include_context 'special user'

        before { setup }
      end
    RUBY
  end

  it 'ignores single-line example blocks' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        include_examples 'special user' do
          before { setup }
        end
      end
    RUBY
  end

  context 'when Ruby 2.7', :ruby27 do
    it 'flags `around` after `it`' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          it { is_expected.to be_after_around_hook }
          around { _1 }
          ^^^^^^^^^^^^^ Move `around` above the examples in the group.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { _1 }
          it { is_expected.to be_after_around_hook }
        end
      RUBY
    end

    it 'flags `around` after `context`' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          context 'a context' do
            it { is_expected.to be_after_around_hook }
          end

          around { _1 }
          ^^^^^^^^^^^^^ Move `around` above the examples in the group.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { _1 }
          context 'a context' do
            it { is_expected.to be_after_around_hook }
          end

        end
      RUBY
    end

    it 'flags `around` after `include_examples`' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          include_examples('should be after around-hook')

          around { _1 }
          ^^^^^^^^^^^^^ Move `around` above the examples in the group.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { _1 }
          include_examples('should be after around-hook')

        end
      RUBY
    end
  end

  context 'when Ruby 3.4', :ruby34 do
    it 'flags `around` after `it`' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          it { is_expected.to be_after_around_hook }
          around { it }
          ^^^^^^^^^^^^^ Move `around` above the examples in the group.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { it }
          it { is_expected.to be_after_around_hook }
        end
      RUBY
    end

    it 'flags `around` after `context`' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          context 'a context' do
            it { is_expected.to be_after_around_hook }
          end

          around { it }
          ^^^^^^^^^^^^^ Move `around` above the examples in the group.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { it }
          context 'a context' do
            it { is_expected.to be_after_around_hook }
          end

        end
      RUBY
    end

    it 'flags `around` after `include_examples`' do
      expect_offense(<<~RUBY)
        RSpec.describe User do
          include_examples('should be after around-hook')

          around { it }
          ^^^^^^^^^^^^^ Move `around` above the examples in the group.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          around { it }
          include_examples('should be after around-hook')

        end
      RUBY
    end
  end
end
