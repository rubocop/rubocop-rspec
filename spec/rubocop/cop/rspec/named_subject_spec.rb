# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::NamedSubject, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples_for 'checking subject outside of shared examples' do
    it 'checks `it` and `specify` for explicit subject usage' do
      expect_offense(<<-RUBY)
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
      expect_offense(<<-RUBY)
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
      expect_offense(<<-RUBY)
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
      expect_no_offenses(<<-RUBY)
        def foo
          it(subject)
        end
      RUBY
    end
  end

  context 'when IgnoreSharedExamples is false' do
    let(:cop_config) { { 'IgnoreSharedExamples' => false } }

    it_behaves_like 'checking subject outside of shared examples'

    it 'checks shared_examples for explicit subject usage' do
      expect_offense(<<-RUBY)
        RSpec.describe User do
          subject(:new_user) { described_class.new }

          shared_examples_for 'a valid new user' do
            it "is a User" do
              expect(subject).to be_a(User)
                     ^^^^^^^ Name your test subject if you need to reference it explicitly.
            end

            it "is valid" do
              expect(subject.valid?).to be(true)
                     ^^^^^^^ Name your test subject if you need to reference it explicitly.
            end

            it "is new" do
              expect(subject).to be_new_record
                     ^^^^^^^ Name your test subject if you need to reference it explicitly.
            end
          end
        end
      RUBY
    end
  end

  context 'when IgnoreSharedExamples is true' do
    let(:cop_config) { { 'IgnoreSharedExamples' => true } }

    it_behaves_like 'checking subject outside of shared examples'

    it 'ignores explicit subject in shared_examples' do
      expect_no_offenses(<<-RUBY)
        RSpec.describe User do
          subject(:new_user) { described_class.new }

          shared_examples_for 'a valid new user' do
            it "is a User" do
              expect(subject).to be_a(User)
            end

            it "is valid" do
              expect(subject.valid?).to be(true)
            end

            it "is new" do
              expect(subject).to be_new_record
            end
          end
        end
      RUBY
    end
  end
end
