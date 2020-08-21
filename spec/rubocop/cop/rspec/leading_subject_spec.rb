# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeadingSubject do
  subject(:cop) { described_class.new }

  it 'checks subject below let' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `let` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        let(:params) { foo }

      end
    RUBY
  end

  it 'checks subject below let!' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let!(:params) { foo }

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `let!` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        let!(:params) { foo }

      end
    RUBY
  end

  it 'checks subject below let with proc argument' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let(:user, &args[:build_user])

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `let` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        let(:user, &args[:build_user])

      end
    RUBY
  end

  it 'approves of subject above let' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:params) { foo }

        context 'blah' do
        end
      end
    RUBY
  end

  it 'handles subjects in contexts' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }

        context "when something happens" do
          subject { described_class.new }
        end
      end
    RUBY
  end

  it 'handles subjects in tests' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        # This shouldn't really ever happen in a sane codebase but I still
        # want to avoid false positives
        it "doesn't mind me calling a method called subject in the test" do
          let(foo)
          subject { bar }
        end
      end
    RUBY
  end

  it 'checks subject below hook' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        before { allow(Foo).to receive(:bar) }

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `before` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        before { allow(Foo).to receive(:bar) }

      end
    RUBY
  end

  it 'checks subject below example' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it { is_expected.to be_present }

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `it` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        it { is_expected.to be_present }

      end
    RUBY
  end

  it 'checks also when subject is below a non-offending node' do
    expect_offense(<<~RUBY)
      RSpec.describe do
        def helper_method
        end

        it { is_expected.to be_present }

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `it` declarations.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        def helper_method
        end

        subject { described_class.new }
        it { is_expected.to be_present }

      end
    RUBY
  end

  it 'flags subject below example group' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        describe do
          it { is_expected.to be_present }
        end

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `describe` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        describe do
          it { is_expected.to be_present }
        end

      end
    RUBY
  end

  it 'flags subject below shared example group' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        shared_examples_for 'used later' do
          it { is_expected.to be_present }
        end

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `shared_examples_for` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        shared_examples_for 'used later' do
          it { is_expected.to be_present }
        end

      end
    RUBY
  end

  it 'flags subject below include' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like 'a good citizen'

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `it_behaves_like` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        it_behaves_like 'a good citizen'

      end
    RUBY
  end

  it 'flags subject below include with a block' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like 'a good citizen' do
          let(:used_in_shared_examples) { 'something' }
        end

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `it_behaves_like` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        it_behaves_like 'a good citizen' do
          let(:used_in_shared_examples) { 'something' }
        end

      end
    RUBY
  end

  it 'flags subject below include with a blockpass' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        block = ->{ }
        it_behaves_like 'a good citizen', &block

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `it_behaves_like` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        block = ->{ }
        subject { described_class.new }
        it_behaves_like 'a good citizen', &block

      end
    RUBY
  end

  it 'ignores subject nested inside a block' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:foo) { 'bar' }

        it_behaves_like 'a good citizen' do
          subject { described_class.new }
        end
      end
    RUBY
  end
end
