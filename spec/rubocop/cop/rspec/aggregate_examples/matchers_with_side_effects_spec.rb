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

  context 'with default configuration' do
    let(:cop_config) { {} }

    context 'without qualifiers' do
      offensive_source = <<-RUBY
        describe 'with and without side effects' do
          it { expect(fruit).to be_good }
          it { expect(fruit).to validate_presence_of(:color) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      it 'detects an offense, but does not correct it' do
        expect_offense(offensive_source)
        expect_no_corrections
      end
    end

    context 'with qualifiers' do
      offensive_source = <<-RUBY
        describe 'with and without side effects' do
          it { expect(fruit).to be_good }
          it { expect(fruit).to allow_value('green').for(:color) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
          it { expect(fruit).to allow_value('green').for(:color).for(:type => :apple) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
          it { expect(fruit).to allow_value('green').for(:color).for(:type => :apple).during(:summer) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2. IMPORTANT! Pay attention to the expectation order, some of the matchers have side effects.
        end
      RUBY

      it 'detects an offense, but does not correct it' do
        expect_offense(offensive_source)
        expect_no_corrections
      end
    end
  end
end
