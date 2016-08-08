# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeadingSubject do
  subject(:cop) { described_class.new }

  it 'checks subject below let' do
    expect_violation(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }

        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare `subject` above any other `let` declarations
      end
    RUBY
  end

  it 'approves of subject above let' do
    expect_no_violations(<<-RUBY)
      RSpec.describe User do
        context 'blah' do
        end

        subject { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'handles subjects in contexts' do
    expect_no_violations(<<-RUBY)
      RSpec.describe User do
        let(:params) { foo }

        context "when something happens" do
          subject { described_class.new }
        end
      end
    RUBY
  end

  it 'handles subjects in tests' do
    expect_no_violations(<<-RUBY)
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
end
