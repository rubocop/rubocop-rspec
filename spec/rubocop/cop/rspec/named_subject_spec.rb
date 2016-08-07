# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::NamedSubject do
  subject(:cop) { described_class.new }

  include_examples 'an rspec only cop'

  it 'checks `it` and `specify` for explicit subject usage' do
    expect_violation(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        it "is valid" do
          expect(subject.valid?).to be(true)
                 ^^^^^^^ Name your test subject if you need to reference it explicitly.
        end

        specify do
          expect(subject.valid?).to be(true)
                 ^^^^^^^ Name your test subject if you need to reference it explicitly.
        end
      end
    RUBY
  end

  it 'checks before and after for explicit subject usage' do
    expect_violation(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        before(:each) do
          do_something_with(subject)
                            ^^^^^^^ Name your test subject if you need to reference it explicitly.
        end

        after do
          do_something_with(subject)
                            ^^^^^^^ Name your test subject if you need to reference it explicitly.
        end
      end
    RUBY
  end

  it 'checks around(:each) for explicit subject usage' do
    expect_violation(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        around(:each) do |test|
          do_something_with(subject)
                            ^^^^^^^ Name your test subject if you need to reference it explicitly.
        end
      end
    RUBY
  end

  it 'ignores subject when not wrapped inside a test' do
    expect_no_violations(<<-RUBY)
      def foo
        it(subject)
      end
    RUBY
  end
end
