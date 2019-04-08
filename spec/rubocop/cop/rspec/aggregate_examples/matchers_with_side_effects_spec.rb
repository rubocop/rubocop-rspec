RSpec.describe RuboCop::Cop::RSpec::AggregateExamples,
               '.matchers_with_side_effects', :config do
  subject(:cop) { described_class.new(config) }

  context 'without no side effect matchers defined in configuration' do
    let(:cop_config) do
      { 'MatchersWithSideEffects' => [] }
    end

    offensive_source = <<-RUBY
      describe do
        it { expect(entry).to validate_absence_of(:comment) }
        it { expect(entry).to validate_presence_of(:description) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
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
    let(:cop_config) { {} }

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
