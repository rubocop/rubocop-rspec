RSpec.describe RuboCop::Cop::RSpec::AggregateExamples, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { {} }

  shared_examples 'detects and autocorrects' do |offensive_source, good_source|
    it 'does not detect an offense in good_source code' do
      expect_no_offenses(good_source)
    end

    it 'detects an offense in offensive source code' do
      expect_offense(offensive_source)
    end

    bad_code_without_message =
      offensive_source.lines.delete_if { |line| line =~ /\A\s*\^/ }.join
    include_examples 'autocorrect', bad_code_without_message, good_source
  end

  shared_examples 'detects, but does not autocorrect' do |offensive_source|
    it 'detects an offense in offensive source code code' do
      expect_offense(offensive_source)
    end

    it 'does not autorcorrect source code' do
      bad_code_without_message =
        offensive_source.lines.delete_if { |line| line =~ /\A\s*\^/ }.join
      expect(autocorrect_source(bad_code_without_message))
        .to eq(bad_code_without_message)
    end
  end

  shared_examples 'detects and autocorrects in example group' do |group|
    context "with '#{group}'" do
      context 'with `is_expected`' do
        offensive_source = <<-RUBY
          #{group} 'aggregations' do
            it { is_expected.to be_awesome }
            it { is_expected.to be_cool }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
          end
        RUBY

        good_source = <<-RUBY
          #{group} 'aggregations' do
            specify do
              is_expected.to be_awesome
              is_expected.to be_cool
            end
          end
        RUBY

        it_behaves_like 'detects and autocorrects',
                        offensive_source, good_source
      end

      context 'with `expect(something)`' do
        offensive_source = <<-RUBY
          #{group} 'aggregations' do
            it { expect(something).to be_awesome }
            it { expect(something).to be_cool }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
          end
        RUBY

        good_source = <<-RUBY
          #{group} 'aggregations' do
            specify do
              expect(something).to be_awesome
              expect(something).to be_cool
            end
          end
        RUBY

        it_behaves_like 'detects and autocorrects',
                        offensive_source, good_source
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
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        its(:another) { is_expected.to be(nil) }
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

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with `its` with array syntax' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        its([:one]) { is_expected.to be(true) }
        it { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    it_behaves_like 'detects, but does not autocorrect', offensive_source
  end

  context 'with examples with non-expectation statements' do
    it 'does not detect offenses' do
      expect_no_offenses(<<-RUBY)
        describe 'aggregations' do
          specify do
            something
            is_expected.to be_cool
          end
          it { is_expected.to be_awesome }
        end
      RUBY
      expect_no_offenses(<<-RUBY)
        describe 'aggregations' do
          it { is_expected.to be_awesome }
          specify do
            something
            is_expected.to be_cool
          end
        end
      RUBY
    end
  end

  context 'with a leading single expectation example' do
    offensive_source = <<-RUBY
      describe do
        it { is_expected.to be_positive }
        specify do
        ^^^^^^^^^^ Aggregate with the example above.
          is_expected.to be_enthusiastic
          is_expected.to be_skilled
        end
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          is_expected.to be_positive
          is_expected.to be_enthusiastic
          is_expected.to be_skilled
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with a following single expectation example' do
    offensive_source = <<-RUBY
      describe do
        specify do
          is_expected.to be_enthusiastic
          is_expected.to be_skilled
        end
        it { is_expected.to be_positive }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          is_expected.to be_enthusiastic
          is_expected.to be_skilled
          is_expected.to be_positive
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with an expectation with chaining matchers' do
    offensive_source = <<-RUBY
      describe do
        specify do
          is_expected
            .to be_enthusiastic
            .and be_hard_working
        end
        it { is_expected.to be_positive }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          is_expected
            .to be_enthusiastic
            .and be_hard_working
          is_expected.to be_positive
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with scattered aggregateable examples' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it { is_expected.to be_first }
        specify do
          foo
          is_expected.to be_foo
        end
        it { is_expected.to be_second }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        specify do
          bar
          is_expected.to be_bar
        end
        it { is_expected.to be_third }
      end
    RUBY

    good_source = <<-RUBY
      describe 'aggregations' do
        specify do
          is_expected.to be_first
          is_expected.to be_second
          is_expected.to be_third
        end
        specify do
          foo
          is_expected.to be_foo
        end
        specify do
          bar
          is_expected.to be_bar
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with example name' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it('is valid') { is_expected.to be_awesome }
        it { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    it_behaves_like 'detects, but does not autocorrect', offensive_source
  end

  context 'when all examples have names' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it('is valid') { is_expected.to be_awesome }
        it('is cool') { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    it_behaves_like 'detects, but does not autocorrect', offensive_source
  end

  context 'with hash metadata' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it { is_expected.to be_mild }
        it(freeze: -30) { is_expected.to be_cold }
        it(aggregate_failures: true) { is_expected.to be_warm }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        it(freeze: -30, aggregate_failures: true) { is_expected.to be_chilly }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        it(aggregate_failures: true, freeze: -30) { is_expected.to be_cool }
      end
    RUBY

    good_source = <<-RUBY
      describe 'aggregations' do
        specify do
          is_expected.to be_mild
          is_expected.to be_warm
        end
        specify(freeze: -30) do
          is_expected.to be_cold
          is_expected.to be_chilly
          is_expected.to be_cool
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with symbol metadata' do
    offensive_source = <<-RUBY
      describe do
        it { is_expected.to be_so_so }
        it(:awesome) { is_expected.to be_awesome }
        it(:awesome, aggregate_failures: true) { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        it(:awesome, :aggregate_failures) { is_expected.to be_amazing }
      end
    RUBY

    good_source = <<-RUBY
      describe do
        it { is_expected.to be_so_so }
        specify(:awesome) do
          is_expected.to be_awesome
          is_expected.to be_cool
          is_expected.to be_amazing
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with `aggregate_failures: false` in metadata' do
    fair_source = <<-RUBY
      describe do
        it(:awesome) { is_expected.to be_awesome }
        it(:awesome, aggregate_failures: false) { is_expected.to be_cool }
        it(:awesome, aggregate_failures: false) { is_expected.to be_amazing }
      end
    RUBY

    it { expect_no_offenses(fair_source) }
  end

  context 'with mixed aggregate_failures in metadata' do
    fair_source = <<-RUBY
      describe do
        it(:awesome, aggregate_failures: true) { is_expected.to be_cool }
        it(:awesome, aggregate_failures: false) { is_expected.to be_amazing }
      end
    RUBY

    it { expect_no_offenses(fair_source) }
  end

  context 'with metadata and title' do
    offensive_source = <<-RUBY
      describe do
        it { is_expected.to be_so_so }
        it(:awesome) { is_expected.to be_awesome }
        it('is ok', :awesome) { is_expected.to be_ok }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    it_behaves_like 'detects, but does not autocorrect', offensive_source
  end

  context 'with mixed metadata' do
    offensive_source = <<-RUBY
      describe do
        it { is_expected.to be_ok }
        it(:model, isolation: :full) { is_expected.to be_isolated }
        it(:model, isolation: :full) { is_expected.to be_save_model }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        it { is_expected.to be_ok }
        specify(:model, isolation: :full) do
          is_expected.to be_isolated
          is_expected.to be_save_model
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with validation actions with side effects' do
    context 'without configuration' do
      let(:cop_config) do
        { 'MatchersWithSideEffects' => [] }
      end

      offensive_source = <<-RUBY
        describe 'aggregations' do
          it { is_expected.to validate_absence_of(:comment) }
          it { is_expected.to validate_presence_of(:description) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        end
      RUBY

      good_source = <<-RUBY
        describe 'aggregations' do
          specify do
            is_expected.to validate_absence_of(:comment)
            is_expected.to validate_presence_of(:description)
          end
        end
      RUBY

      it_behaves_like 'detects and autocorrects', offensive_source, good_source
    end

    context 'with `is_expected`' do
      offensive_source = <<-RUBY
        describe 'aggregations' do
          it { is_expected.to validate_absence_of(:comment) }
          it { is_expected.to validate_presence_of(:description) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      it_behaves_like 'detects, but does not autocorrect', offensive_source
    end

    context 'with `expect(something)`' do
      offensive_source = <<-RUBY
        describe 'aggregations' do
          it { expect(something).to validate_absence_of(:comment) }
          it { expect(something).to validate_presence_of(:description) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      it_behaves_like 'detects, but does not autocorrect', offensive_source
    end

    context 'with `not_to`' do
      offensive_source = <<-RUBY
        describe 'aggregations' do
          it { is_expected.not_to validate_absence_of(:comment) }
          it { is_expected.to_not validate_presence_of(:description) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      it_behaves_like 'detects, but does not autocorrect', offensive_source
    end
  end

  context 'with validation actions with side effects' do
    offensive_source = <<-RUBY
      describe do
        describe 'without side effects' do
          it { is_expected.to be_good }
          it { is_expected.to be_cheap }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
          context 'with side effects' do
            it { is_expected.to validate_presence_of(:comment) }
          end
        end
      end
    RUBY

    it 'detects an offense in offensive_source code' do
      expect_offense(offensive_source)
    end
  end

  context 'with examples defined in the loop' do
    fair_source = <<-RUBY
      describe 'aggregations' do
        [1, 2, 3].each do
          it { is_expected.to be_mild }
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
          is_expected.to span_couple_lines <<-TEXT
            Multiline text.
            Second line.
          TEXT
        end
        it { is_expected.to be_ok }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    it_behaves_like 'detects, but does not autocorrect', offensive_source
  end

  context 'with HEREDOC interleaved with parenthesis and curly brace' do
    offensive_source = <<-RUBY
      describe 'aggregations' do
        it { is_expected.to span_couple_lines(<<-TEXT) }
          I would be quite surprised to see this in the code.
          But it's real!
        TEXT
        it { is_expected.to be_ok }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    it_behaves_like 'detects, but does not autocorrect', offensive_source
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
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
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

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
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
        it { is_expected.to be_ok }

        context do
          it { is_expected.to be_ok }
        end

        context do
          it { is_expected.to be_ok }
        end
      end
    RUBY

    it 'does not detect offenses' do
      expect_no_offenses(fair_source)
    end
  end

  context 'with aggregateable examples and nested example groups' do
    offensive_source = <<-RUBY
      describe do
        it { is_expected.to be_ok }
        it { is_expected.to be_alright }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.

        context do
          it { is_expected.to be_awful }
        end
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          is_expected.to be_ok
          is_expected.to be_alright
        end

        context do
          it { is_expected.to be_awful }
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'when in root context' do
    offensive_source = <<-RUBY
      RSpec.describe do
        it { is_expected.to be_positive }
        it { is_expected.to be_enthusiastic }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    good_source = <<-RUBY
      RSpec.describe do
        specify do
          is_expected.to be_positive
          is_expected.to be_enthusiastic
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with several examples separated by newlines' do
    offensive_source = <<-RUBY
      RSpec.describe do
        it { is_expected.to be_positive }

        it { is_expected.to be_enthusiastic }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    good_source = <<-RUBY
      RSpec.describe do
        specify do
          is_expected.to be_positive
          is_expected.to be_enthusiastic
        end
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'with scattered examples separated by newlines' do
    offensive_source = <<-RUBY
      RSpec.describe do
        it { is_expected.to be_positive }

        it { expect { something }.to do_something }
        it { is_expected.to be_enthusiastic }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
      end
    RUBY

    good_source = <<-RUBY
      RSpec.describe do
        specify do
          is_expected.to be_positive
          is_expected.to be_enthusiastic
        end

        it { expect { something }.to do_something }
      end
    RUBY

    it_behaves_like 'detects and autocorrects', offensive_source, good_source
  end

  context 'when EnforcedStyle is :add_aggregate_failures_metadata' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'add_aggregate_failures_metadata' }
    end

    context 'with no metadata on example' do
      offensive_source = <<-RUBY
        describe do
          it { is_expected.to be_first }
          it { is_expected.to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures) do
            is_expected.to be_first
            is_expected.to be_second
          end
        end
      RUBY

      it_behaves_like 'detects and autocorrects', offensive_source, good_source
    end

    context 'with hash metadata' do
      offensive_source = <<-RUBY
        describe do
          it(allow: true) { is_expected.to be_first }
          it(allow: true) { is_expected.to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures, allow: true) do
            is_expected.to be_first
            is_expected.to be_second
          end
        end
      RUBY

      it_behaves_like 'detects and autocorrects', offensive_source, good_source
    end

    context 'with symbol metadata' do
      offensive_source = <<-RUBY
        describe do
          it(:allow) { is_expected.to be_first }
          it(:allow) { is_expected.to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures, :allow) do
            is_expected.to be_first
            is_expected.to be_second
          end
        end
      RUBY

      it_behaves_like 'detects and autocorrects', offensive_source, good_source
    end

    context 'with mixed metadata' do
      offensive_source = <<-RUBY
        describe do
          it(:follow, allow: true) { is_expected.to be_first }
          it(:follow, allow: true) { is_expected.to be_second }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example above.
        end
      RUBY

      good_source = <<-RUBY
        describe do
          specify(:aggregate_failures, :follow, allow: true) do
            is_expected.to be_first
            is_expected.to be_second
          end
        end
      RUBY

      it_behaves_like 'detects and autocorrects', offensive_source, good_source
    end
  end
end
