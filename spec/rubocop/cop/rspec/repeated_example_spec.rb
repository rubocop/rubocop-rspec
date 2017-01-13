# frozen_string_literal: true

describe RuboCop::Cop::RSpec::RepeatedExample do
  subject(:cop) { described_class.new }

  it 'registers an offense for repeated example' do
    expect_violation(<<-RUBY)
      describe 'doing x' do
        it "does x" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group.
          expect(foo).to be(bar)
        end

        it "does y" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group.
          expect(foo).to be(bar)
        end
      end
    RUBY
  end

  it 'does not register a violation if rspec tag magic is involved' do
    expect_no_violations(<<-RUBY)
      describe 'doing x' do
        it "does x" do
          expect(foo).to be(bar)
        end

        it "does y", :focus do
          expect(foo).to be(bar)
        end
      end
    RUBY
  end

  it 'does not flag examples with different implementations' do
    expect_no_violations(<<-RUBY)
      describe 'doing x' do
        it "does x" do
          expect(foo).to have_attribute(foo: 1)
        end

        it "does y" do
          expect(foo).to have_attribute(bar: 2)
        end
      end
    RUBY
  end

  it 'does not flag repeated examples in different scopes' do
    expect_no_violations(<<-RUBY)
      describe 'doing x' do
        it "does x" do
          expect(foo).to be(bar)
        end

        context 'when the scope changes' do
          it 'does not flag anything' do
            expect(foo).to be(bar)
          end
        end
      end
    RUBY
  end
end
