RSpec.describe RuboCop::Cop::RSpec::AggregateExamples, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { {} }

  shared_examples 'detects and autocorrects in example group' do |group|
    context "with '#{group}'" do
      offensive_source = <<-RUBY
        #{group} 'aggregations' do
          it { is_expected.to be_awesome }
          it { expect(subject).to be_amazing }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
          it { expect(article).to be_brilliant }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        end
      RUBY

      good_source = <<-RUBY
        #{group} 'aggregations' do
          specify do
            is_expected.to be_awesome
            expect(subject).to be_amazing
            expect(article).to be_brilliant
          end
        end
      RUBY

      it 'detects and autocorrects' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end
  end

  it_behaves_like 'detects and autocorrects in example group', :context
  it_behaves_like 'detects and autocorrects in example group', :describe
  it_behaves_like 'detects and autocorrects in example group', :feature
  it_behaves_like 'detects and autocorrects in example group',
                  :example_group

  context 'with `its`' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        its(:one) { is_expected.to be(true) }
        it { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        its(:another) { is_expected.to be(nil) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe 'aggregations' do
        specify do
          expect(subject.one).to be(true)
          is_expected.to be_cool
          expect(subject.another).to be(nil)
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with `its` with array syntax' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        its([:one]) { is_expected.to be(true) }
        it { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  # Non-expectation statements can have side effects, when e.g. being
  # part of the setup of the example.
  # Examples containing expectations wrapped in a method call, e.g.
  # `expect_no_corrections` are not considered aggregatable.
  context 'with examples with non-expectation statements' do
    it 'does not detect offenses' do
      expect_no_offenses(<<-RUBY)
        describe 'aggregations' do
          specify do
            something
            expect(book).to be_cool
          end
          it { expect(book).to be_awesome }
        end
      RUBY
      expect_no_offenses(<<-RUBY)
        describe 'aggregations' do
          it { expect(book).to be_awesome }
          specify do
            something
            expect(book).to be_cool
          end
        end
      RUBY
    end
  end

  # Both one-line examples and examples spanning multiple lines can be
  # aggregated, in case they consist only of expectation statements.
  context 'with a leading single expectation example' do
    offensive_source = <<-RUBY
      describe do
        it { expect(candidate).to be_positive }
        specify do
        ^^^^^^^^^^ Aggregate with the example at line 2.
          expect(subject).to be_enthusiastic
          is_expected.to be_skilled
        end
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(candidate).to be_positive
          expect(subject).to be_enthusiastic
          is_expected.to be_skilled
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with a following single expectation example' do
    offensive_source = <<-RUBY
      describe do
        specify do
          expect(subject).to be_enthusiastic
          is_expected.to be_skilled
        end
        it { expect(candidate).to be_positive }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(subject).to be_enthusiastic
          is_expected.to be_skilled
          expect(candidate).to be_positive
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with an expectation with chaining matchers' do
    offensive_source = <<-RUBY
      describe do
        specify do
          expect(candidate)
            .to be_enthusiastic
            .and be_hard_working
        end
        it { is_expected.to be_positive }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(candidate)
            .to be_enthusiastic
            .and be_hard_working
          is_expected.to be_positive
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with scattered aggregateable examples' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it { expect(life).to be_first }
        specify do
          foo
          expect(bar).to be_foo
        end
        it { expect(work).to be_second }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        specify do
          bar
          expect(foo).to be_bar
        end
        it { expect(other).to be_third }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe 'aggregations' do
        specify do
          expect(life).to be_first
          expect(work).to be_second
          expect(other).to be_third
        end
        specify do
          foo
          expect(bar).to be_foo
        end
        specify do
          bar
          expect(foo).to be_bar
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with example name' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it('is awesome') { expect(drink).to be_awesome }
        it { expect(drink).to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  context 'when all examples have names' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it('is awesome') { expect(drink).to be_awesome }
        it('is cool') { expect(drink).to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  context 'with hash metadata' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it { expect(ambient_temperature).to be_mild }
        it(freeze: -30) { expect(ambient_temperature).to be_cold }
        it(aggregate_failures: true) { expect(ambient_temperature).to be_warm }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        it(freeze: -30, aggregate_failures: true) { expect(ambient_temperature).to be_chilly }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 3.
        it(aggregate_failures: true, freeze: -30) { expect(ambient_temperature).to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 3.
      end
    RUBY

    good_source = <<-RUBY
      describe 'aggregations' do
        specify do
          expect(ambient_temperature).to be_mild
          expect(ambient_temperature).to be_warm
        end
        specify(freeze: -30) do
          expect(ambient_temperature).to be_cold
          expect(ambient_temperature).to be_chilly
          expect(ambient_temperature).to be_cool
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  # Same as above
  context 'with symbol metadata' do
    offensive_source = <<-RUBY
      describe do
        it { expect(fruit).to be_so_so }
        it(:peach) { expect(fruit).to be_awesome }
        it(:peach, aggregate_failures: true) { expect(fruit).to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 3.
        it(:peach, :aggregate_failures) { expect(fruit).to be_amazing }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 3.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        it { expect(fruit).to be_so_so }
        specify(:peach) do
          expect(fruit).to be_awesome
          expect(fruit).to be_cool
          expect(fruit).to be_amazing
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with `aggregate_failures: false` in metadata' do
    fair_source = <<-RUBY
      describe do
        it(:awesome) { expect(fruit).to be_awesome }
        it(:awesome, aggregate_failures: false) { expect(fruit).to be_cool }
        it(:awesome, aggregate_failures: false) { expect(fruit).to be_amazing }
      end
    RUBY

    it { expect_no_offenses(fair_source) }
  end

  context 'with mixed aggregate_failures in metadata' do
    fair_source = <<-RUBY
      describe do
        it(:awesome, aggregate_failures: true) { expect(fruit).to be_cool }
        it(:awesome, aggregate_failures: false) { expect(fruit).to be_amazing }
      end
    RUBY

    it { expect_no_offenses(fair_source) }
  end

  context 'with metadata and title' do
    offensive_source = <<-RUBY
      describe do
        it { expect(dragonfruit).to be_so_so }
        it(:awesome) { expect(dragonfruit).to be_awesome }
        it('is ok', :awesome) { expect(dragonfruit).to be_ok }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 3.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  context 'with mixed metadata' do
    offensive_source = <<-RUBY
      describe do
        it { expect(data).to be_ok }
        it(:model, isolation: :full) { expect(data).to be_isolated }
        it(:model, isolation: :full) { expect(data).to be_saved }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 3.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        it { expect(data).to be_ok }
        specify(:model, isolation: :full) do
          expect(data).to be_isolated
          expect(data).to be_saved
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with matchers with side effects' do
    context 'without no side effect matchers defined in configuration' do
      let(:cop_config) do
        { 'MatchersWithSideEffects' => [] }
      end

      offensive_source = <<-RUBY
        describe 'aggregations' do
          it { expect(entry).to validate_absence_of(:comment) }
          it { expect(entry).to validate_presence_of(:description) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        end
      RUBY

      good_source = <<-RUBY
        describe 'aggregations' do
          specify do
            expect(entry).to validate_absence_of(:comment)
            expect(entry).to validate_presence_of(:description)
          end
        end
      RUBY

      it 'detects and autocorrects' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end

    context 'with the default configuration' do
      offensive_source = <<-RUBY
        describe 'aggregations' do
          it { expect(entry).to validate_absence_of(:comment) }
          it { expect(entry).to validate_presence_of(:description) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      it 'detects an offense, but does not correct it' do
        expect_offense(offensive_source)
        expect_no_corrections
      end
    end

    context 'with mixed matchers' do
      offensive_source = <<-RUBY
        describe 'with and without side effects' do
          it { expect(fruit).to be_good }
          it { expect(fruit).to be_cheap }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
          it { expect(fruit).to validate_presence_of(:color) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      good_source = <<-RUBY
        describe 'with and without side effects' do
          specify do
            expect(fruit).to be_good
            expect(fruit).to be_cheap
          end
          it { expect(fruit).to validate_presence_of(:color) }
        end
      RUBY

      it 'detects an offense in offensive_source code' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end
  end

  context 'with examples defined in the loop' do
    fair_source = <<-RUBY
      describe 'aggregations' do
        [1, 2, 3].each do
          it { expect(weather).to be_mild }
        end
      end
    RUBY

    it 'does not detect offenses' do
      expect_no_offenses(fair_source)
    end
  end

  context 'with HEREDOC' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        specify do
          expect(text).to span_couple_lines <<-TEXT
            Multiline text.
            Second line.
          TEXT
        end
        it { expect(text).to be_ok }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  context 'with HEREDOC interleaved with parenthesis and curly brace' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it { expect(text).to span_couple_lines(<<-TEXT) }
          I would be quite surprised to see this in the code.
          But it's real!
        TEXT
        it { expect(text).to be_ok }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  context 'with block expectation syntax' do
    fair_source = <<-RUBY
      describe '#complete' do
        specify do
          expect { something }.to do_something
        end

        specify do
          expect { something }.to do_something_else
        end
      end
    RUBY

    it 'does not detect offenses' do
      expect_no_offenses(fair_source)
    end
  end

  context 'with a property of something as subject' do
    offensive_source = <<-RUBY
      describe do
        it { expect(division.result).to eq(5) }
        it { expect(division.modulo).to eq(3) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(division.result).to eq(5)
          expect(division.modulo).to eq(3)
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with helper method as subject' do
    fair_source = <<-RUBY
      describe do
        specify do
          expect(multiply_by(2)).to be_multiple_of(2)
        end

        specify do
          expect(multiply_by(3)).to be_multiple_of(3)
        end
      end
    RUBY

    it 'does not detect offenses' do
      expect_no_offenses(fair_source)
    end
  end

  context 'with nested example groups' do
    fair_source = <<-RUBY
      describe do
        it { expect(syntax_check).to be_ok }

        context do
          it { expect(syntax_check).to be_ok }
        end

        context do
          it { expect(syntax_check).to be_ok }
        end
      end
    RUBY

    it 'does not detect offenses' do
      expect_no_offenses(fair_source)
    end
  end

  context 'with aggregatable examples and nested example groups' do
    offensive_source = <<-RUBY
      describe do
        it { expect(pressure).to be_ok }
        it { expect(pressure).to be_alright }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.

        context do
          it { expect(pressure).to be_awful }
        end
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(pressure).to be_ok
          expect(pressure).to be_alright
        end

        context do
          it { expect(pressure).to be_awful }
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'when in root context' do
    offensive_source = <<-RUBY
      RSpec.describe do
        it { expect(person).to be_positive }
        it { expect(person).to be_enthusiastic }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      RSpec.describe do
        specify do
          expect(person).to be_positive
          expect(person).to be_enthusiastic
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with several examples separated by newlines' do
    offensive_source = <<-RUBY
      RSpec.describe do
        it { expect(person).to be_positive }

        it { expect(person).to be_enthusiastic }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      RSpec.describe do
        specify do
          expect(person).to be_positive
          expect(person).to be_enthusiastic
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'with scattered examples separated by newlines' do
    offensive_source = <<-RUBY
      RSpec.describe do
        it { expect(person).to be_positive }

        it { expect { something }.to do_something }
        it { expect(person).to be_enthusiastic }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      RSpec.describe do
        specify do
          expect(person).to be_positive
          expect(person).to be_enthusiastic
        end

        it { expect { something }.to do_something }
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  context 'when AddAggregateFailuresMetadata is true' do
    let(:cop_config) do
      { 'AddAggregateFailuresMetadata' => true }
    end

    context 'with no metadata on example' do
      offensive_source = <<-RUBY
        describe do
          it { expect(life).to be_first }
          it { expect(work).to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures) do
            expect(life).to be_first
            expect(work).to be_second
          end
        end
      RUBY

      it 'detects and autocorrects' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end

    context 'with hash metadata' do
      offensive_source = <<-RUBY
        describe do
          it(allow: true) { expect(life).to be_first }
          it(allow: true) { expect(work).to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures, allow: true) do
            expect(life).to be_first
            expect(work).to be_second
          end
        end
      RUBY

      it 'detects and autocorrects' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end

    context 'with symbol metadata' do
      offensive_source = <<-RUBY
        describe do
          it(:allow) { expect(life).to be_first }
          it(:allow) { expect(work).to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures, :allow) do
            expect(life).to be_first
            expect(work).to be_second
          end
        end
      RUBY

      it 'detects and autocorrects' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end

    context 'with mixed metadata' do
      offensive_source = <<-RUBY
        describe do
          it(:follow, allow: true) { expect(life).to be_first }
          it(:follow, allow: true) { expect(work).to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures, :follow, allow: true) do
            expect(life).to be_first
            expect(work).to be_second
          end
        end
      RUBY

      it 'detects and autocorrects' do
        expect_offense(offensive_source)
        expect_correction(good_source)
      end
    end
  end
end
