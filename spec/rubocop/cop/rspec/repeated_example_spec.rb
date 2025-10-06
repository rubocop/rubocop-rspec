# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedExample do
  it 'registers an offense for repeated example' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "does x" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 6.
          expect(foo).to be(bar)
        end

        it "does y" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2.
          expect(foo).to be(bar)
        end
      end
    RUBY
  end

  it 'does not register an offense if rspec tag magic is involved' do
    expect_no_offenses(<<~RUBY)
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
    expect_no_offenses(<<~RUBY)
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

  it 'registers an offense when repeated its are used' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        its(:x) { is_expected.to be_present }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 3.
        its(:x) { is_expected.to be_present }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2.
      end
    RUBY
  end

  it 'does not flag examples when different its arguments are used' do
    expect_no_offenses(<<~RUBY)
      describe 'doing x' do
        its(:x) { is_expected.to be_present }
        its(:y) { is_expected.to be_present }
      end
    RUBY
  end

  it 'does not flag examples when different its block expectations are used' do
    expect_no_offenses(<<~RUBY)
      describe 'doing x' do
        its(:x) { is_expected.to be_present }
        its(:x) { is_expected.to be_blank }
      end
    RUBY
  end

  it 'does not flag repeated examples in different scopes' do
    expect_no_offenses(<<~RUBY)
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

  it 'shows all duplicate line numbers when there are three duplicates' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "does x" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 6, 10.
          expect(foo).to be(bar)
        end

        it "does y" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 10.
          expect(foo).to be(bar)
        end

        it "does z" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 6.
          expect(foo).to be(bar)
        end
      end
    RUBY
  end

  it 'shows all duplicate line numbers when there are four duplicates' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "first" do
        ^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 5, 8, 11.
          expect(foo).to be(bar)
        end
        it "second" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 8, 11.
          expect(foo).to be(bar)
        end
        it "third" do
        ^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 5, 11.
          expect(foo).to be(bar)
        end
        it "fourth" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 5, 8.
          expect(foo).to be(bar)
        end
      end
    RUBY
  end

  it 'correctly reports duplicates with string interpolation' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        let(:date) { '2024-06-25' }

        it { expect(subject).to be_urgent(order, now: T("\#{date}T12:00")) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 5.
        it { expect(subject).to be_urgent(order, now: T("\#{date}T12:00")) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 4.
      end
    RUBY
  end

  it 'does not flag examples with different string interpolation values' do
    expect_no_offenses(<<~RUBY)
      describe 'doing x' do
        let(:date) { '2024-06-25' }

        it { expect(subject).to be_urgent(order, now: T("\#{date}T12:00")) }
        it { expect(subject).to be_urgent(order, now: T("\#{date}T17:00")) }
      end
    RUBY
  end

  it 'handles one-liner examples with duplicates' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it { is_expected.to be_valid }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 3, 4.
        it { is_expected.to be_valid }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 4.
        it { is_expected.to be_valid }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 3.
      end
    RUBY
  end

  it 'shows line numbers for examples formatted differently but with ' \
     'same AST' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "does x" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 5.
          expect(foo).to be(bar)
        end
        it "does y" do expect(foo).to be(bar); end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2.
      end
    RUBY
  end

  it 'correctly identifies repeated examples across mixed formatting' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "multiline" do
        ^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 5.
          expect(foo).to eq(bar)
        end
        it("single line") { expect(foo).to eq(bar) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2.
      end
    RUBY
  end

  it 'handles multiple examples on same line correctly' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "first" do
        ^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 5.
          expect(foo).to eq(bar)
        end
        it("second") { expect(foo).to eq(bar) }; it("third") { expect(foo).to eq(bar) }
                                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 5.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2, 5.
      end
    RUBY
  end

  it 'does not confuse examples in nested contexts with same implementation' do
    expect_no_offenses(<<~RUBY)
      describe 'doing x' do
        context 'context A' do
          it "does x" do
            expect(foo).to be(bar)
          end
        end

        context 'context B' do
          it "does x" do
            expect(foo).to be(bar)
          end
        end
      end
    RUBY
  end

  it 'flags duplicates only within the same example group' do
    expect_offense(<<~RUBY)
      describe 'doing x' do
        it "first" do
        ^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 5.
          expect(foo).to be(bar)
        end
        it "second" do
        ^^^^^^^^^^^^^^ Don't repeat examples within an example group. Repeated on line(s) 2.
          expect(foo).to be(bar)
        end

        context 'different scope' do
          it "third" do
            expect(foo).to be(bar)
          end
        end
      end
    RUBY
  end
end
