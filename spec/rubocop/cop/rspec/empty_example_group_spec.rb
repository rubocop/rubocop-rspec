# frozen_string_literal: true

describe RuboCop::Cop::RSpec::EmptyExampleGroup do
  subject(:cop) { described_class.new }

  it 'flags an empty context' do
    expect_violation(<<-RUBY)
      describe Foo do
        context 'when bar' do
        ^^^^^^^^^^^^^^^^^^ Empty example group detected.

          let(:foo) { bar }
        end

        describe '#thingy?' do
          specify do
            expect(whatever.thingy?).to be(true)
          end
        end

        it { should be_true }
      end
    RUBY
  end

  it 'flags an empty top level describe' do
    expect_violation(<<-RUBY)
      describe Foo do
      ^^^^^^^^^^^^ Empty example group detected.
      end
    RUBY
  end

  it 'does not flag include_examples' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        context "when something is true" do
          include_examples "some expectations"
        end

        context "when something else is true" do
          include_context "some expectations"
        end

        context "when a third thing is true" do
          it_behaves_like "some thingy"
        end
      end
    RUBY
  end
end
