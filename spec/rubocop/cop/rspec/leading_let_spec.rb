# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeadingLet do
  it 'registers an offense for subject above let' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `subject` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        subject { described_class.new }

      end
    RUBY
  end

  it 'registers an offense for subject above let!' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let!(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `subject` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let!(:params) { foo }
        subject { described_class.new }

      end
    RUBY
  end

  xit 'registers an offense for let below subject with proc argument' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:user, &args[:build_user])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `subject` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:user, &args[:build_user])
        subject { described_class.new }

      end
    RUBY
  end

  it 'does not register an offense for let above subject' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }

        subject { described_class.new }

        context 'blah' do
        end
      end
    RUBY
  end

  it 'does not register an offense for lets in contexts' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        context "when something happens" do
          let(:params) { foo }
        end
      end
    RUBY
  end

  it 'registers an offense for let below hook' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        before { allow(Foo).to receive(:bar) }

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `before` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        before { allow(Foo).to receive(:bar) }

      end
    RUBY
  end

  it 'registers an offense for let below example' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it { is_expected.to be_present }

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `it` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        it { is_expected.to be_present }

      end
    RUBY
  end

  it 'registers an offense when let is below a non-offending node' do
    expect_offense(<<~RUBY)
      RSpec.describe do
        def helper_method
        end

        it { is_expected.to be_present }

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `it` declarations.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe do
        def helper_method
        end

        let(:params) { foo }
        it { is_expected.to be_present }

      end
    RUBY
  end

  it 'registers an offense for let below example group' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        describe do
          it { is_expected.to be_present }
        end

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `describe` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        describe do
          it { is_expected.to be_present }
        end

      end
    RUBY
  end

  it 'registers an offense for let below shared example group' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        shared_examples_for 'used later' do
          it { is_expected.to be_present }
        end

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `shared_examples_for` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        shared_examples_for 'used later' do
          it { is_expected.to be_present }
        end

      end
    RUBY
  end

  it 'registers an offense for let below include' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like 'a good citizen'

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `it_behaves_like` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        it_behaves_like 'a good citizen'

      end
    RUBY
  end

  it 'registers an offense for let below include with a block' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        it_behaves_like 'a good citizen' do
          let(:used_in_shared_examples) { 'something' }
        end

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `it_behaves_like` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        it_behaves_like 'a good citizen' do
          let(:used_in_shared_examples) { 'something' }
        end

      end
    RUBY
  end

  it 'registers an offense for let below include with a blockpass' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        block = ->{ }
        it_behaves_like 'a good citizen', &block

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `it_behaves_like` declarations.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        block = ->{ }
        let(:params) { foo }
        it_behaves_like 'a good citizen', &block

      end
    RUBY
  end

  it 'does not register an offense for let nested inside a block' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subect { described_class.new }

        it_behaves_like 'a good citizen' do
          let(:params) { foo }
        end
      end
    RUBY
  end

  context 'when the let is below both a hook and a subject' do
    it 'registers an offense on the first offending node' do
      expect_offense(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new}
        before { allow(Foo).to receive(:bar) }

        let(:params) { foo }
        ^^^^^^^^^^^^^^^^^^^^ Declare all `let` above any `subject` declarations.
      end
      RUBY

      expect_correction(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }
        subject { described_class.new}
        before { allow(Foo).to receive(:bar) }

      end
      RUBY
    end
  end
end
