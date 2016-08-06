# frozen_string_literal: true

describe RuboCop::Cop::RSpec::MultipleExpectations, :config do
  subject(:cop) { described_class.new(config) }

  context 'without configuration' do
    let(:cop_config) { Hash.new }

    it 'flags multiple expectations' do
      expect_violation(<<-RUBY)
        describe Foo do
          it 'uses expect twice' do
          ^^^^^^^^^^^^^^^^^^^^^^ Too many expectations.
            expect(foo).to eq(bar)
            expect(baz).to eq(bar)
          end
        end
      RUBY
    end

    it 'approves of one expectation per example' do
      expect_no_violations(<<-RUBY)
        describe Foo do
          it 'does something neat' do
            expect(neat).to be(true)
          end

          it 'does something cool' do
            expect(cool).to be(true)
          end
        end
      RUBY
    end
  end

  context 'with configuration' do
    let(:cop_config) do
      { 'Max' => '2' }
    end

    it 'permits two expectations' do
      expect_no_violations(<<-RUBY)
        describe Foo do
          it 'uses expect twice' do
            expect(foo).to eq(bar)
            expect(baz).to eq(bar)
          end
        end
      RUBY
    end

    it 'flags three expectations' do
      expect_violation(<<-RUBY)
        describe Foo do
          it 'uses expect three times' do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Too many expectations.
            expect(foo).to eq(bar)
            expect(baz).to eq(bar)
            expect(qux).to eq(bar)
          end
        end
      RUBY
    end
  end

  it 'generates a todo based on the worst violation' do
    inspect_source(cop, <<-RUBY)
      describe Foo do
        it 'uses expect twice' do
          expect(foo).to eq(bar)
          expect(baz).to eq(bar)
        end

        it 'uses expect three times' do
          expect(foo).to eq(bar)
          expect(baz).to eq(bar)
          expect(qux).to eq(bar)
        end
      end
    RUBY

    expect(cop.config_to_allow_offenses).to eq('Max' => 3)
  end
end
