# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterFinalLet do
  it 'registers an offense for empty line after last let' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }
        ^^^^^^^^^^^^^ Add an empty line after the last `let`.
        it { expect(a).to eq(b) }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'registers an offense for empty line after last let in shared examples' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        shared_examples_for 'some shared behavior' do
          let(:a) { a }
          let(:b) { b }
          ^^^^^^^^^^^^^ Add an empty line after the last `let`.
          it { expect(a).to eq(b) }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        shared_examples_for 'some shared behavior' do
          let(:a) { a }
          let(:b) { b }

          it { expect(a).to eq(b) }
        end
      end
    RUBY
  end

  it 'registers an offense for empty line after last let in' \
     'included examples' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        it_behaves_like 'some shared behavior' do
          let(:a) { a }
          let(:b) { b }
          ^^^^^^^^^^^^^ Add an empty line after the last `let`.
          it { expect(a).to eq(b) }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        it_behaves_like 'some shared behavior' do
          let(:a) { a }
          let(:b) { b }

          it { expect(a).to eq(b) }
        end
      end
    RUBY
  end

  it 'registers an offense for empty line after the last `let!`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let!(:b) do
          b
        end
        ^^^ Add an empty line after the last `let!`.
        it { expect(a).to eq(b) }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let!(:b) do
          b
        end

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'registers an offense for empty line after let with proc argument' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:user, &args[:build_user])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after the last `let`.
        it { expect(a).to eq(b) }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:user, &args[:build_user])

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'does not register an offense for empty line after let' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'does not register an offense for comment ' \
     'followed by an empty line after let' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }
        # end of setup

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'flags a missing empty line before a comment' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }
        ^^^^^^^^^^^^^ Add an empty line after the last `let`.
        # comment
        it { expect(a).to eq(b) }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }

        # comment
        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'flags a missing empty line before a multiline comment' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }
        ^^^^^^^^^^^^^ Add an empty line after the last `let`.
        # multiline comment
        # multiline comment
        it { expect(a).to eq(b) }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }

        # multiline comment
        # multiline comment
        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        let(:a) { a }
        let(:b) { b }
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after the last `let`.
        it { expect(a).to eq(b) }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        let(:a) { a }
        let(:b) { b }
        # rubocop:enable RSpec/Foo

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'flags a missing empty line before a `rubocop:disable` directive' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }
        ^^^^^^^^^^^^^ Add an empty line after the last `let`.
        # rubocop:disable RSpec/Foo
        it { expect(a).to eq(b) }
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }

        # rubocop:disable RSpec/Foo
        it { expect(a).to eq(b) }
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  it 'flags a missing empty line after a `rubocop:enable` directive ' \
     'when it is followed by a `rubocop:disable` directive' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        let(:a) { a }
        let(:b) { b }
        # rubocop:enable RSpec/Foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after the last `let`.
        # rubocop:disable RSpec/Foo
        it { expect(a).to eq(b) }
        # rubocop:enable RSpec/Foo
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        # rubocop:disable RSpec/Foo
        let(:a) { a }
        let(:b) { b }
        # rubocop:enable RSpec/Foo

        # rubocop:disable RSpec/Foo
        it { expect(a).to eq(b) }
        # rubocop:enable RSpec/Foo
      end
    RUBY
  end

  it 'does not register an offense for empty lines between the lets' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }

        subject { described_class }

        let!(:b) { b }

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'does not register an offense for let in tests' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        # This shouldn't really ever happen in a sane codebase but I still
        # want to avoid false positives
        it "doesn't mind me calling a method called let in the test" do
          let(foo)
          subject { bar }
        end
      end
    RUBY
  end

  it 'does not register an offense for multiline let block' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) do
          b
        end

        it { expect(a).to eq(b) }
      end
    RUBY
  end

  it 'does not register an offense for let being the latest node' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:b) { b }
      end
    RUBY
  end

  it 'does not register an offense for HEREDOC for let' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:foo) do
          <<-BAR
          hello
          world
          BAR
        end

        it 'uses heredoc' do
          expect(foo).to eql("  hello\n  world\n")
        end
      end
    RUBY
  end

  it 'does not register an offense for silly HEREDOC syntax for let' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'silly heredoc syntax' do
        let(:foo) { <<-BAR }
        hello
        world
        BAR

        it 'has tricky syntax' do
          expect(foo).to eql("  hello\n  world\n")
        end
      end
    RUBY
  end

  it 'registers an offense for silly HEREDOC offense' do
    expect_offense(<<~RUBY)
      RSpec.describe 'silly heredoc syntax' do
        let(:foo) { <<-BAR }
        hello
        world
        BAR
        ^^^ Add an empty line after the last `let`.
        it 'has tricky syntax' do
          expect(foo).to eql("  hello\n  world\n")
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe 'silly heredoc syntax' do
        let(:foo) { <<-BAR }
        hello
        world
        BAR

        it 'has tricky syntax' do
          expect(foo).to eql("  hello\n  world\n")
        end
      end
    RUBY
  end
end
