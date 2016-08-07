# frozen_string_literal: true

describe RuboCop::Cop::RSpec::LetSetup do
  subject(:cop) { described_class.new }

  include_examples 'an rspec only cop'

  it 'complains when let! is used and not referenced' do
    expect_violation(<<-RUBY)
      describe Foo do
        let!(:foo) { bar }
        ^^^^^^^^^^ Do not use `let!` for test setup.

        it 'does not use foo' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'ignores let! when used in `before`' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        let!(:foo) { bar }

        before do
          foo
        end

        it 'does not use foo' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'ignores let! when used in example' do
    expect_no_violations(<<-RUBY)
      describe Foo do
        let!(:foo) { bar }

        it 'uses foo' do
          foo
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'complains when let! is used and not referenced within nested group' do
    expect_violation(<<-RUBY)
      describe Foo do
        context 'when something special happens' do
          let!(:foo) { bar }
          ^^^^^^^^^^ Do not use `let!` for test setup.

          it 'does not use foo' do
            expect(baz).to eq(qux)
          end
        end

        it 'references some other foo' do
          foo
        end
      end
    RUBY
  end
end
