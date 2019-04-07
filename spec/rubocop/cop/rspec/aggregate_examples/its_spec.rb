RSpec.describe RuboCop::Cop::RSpec::AggregateExamples, '.its' do
  subject(:cop) { described_class.new }

  # Regular `its` call with an attribute/method name, or a chain of methods
  # expressed as a string with dots.
  context 'with `its`' do
    offensive_source = <<-RUBY
      describe do
        its(:one) { is_expected.to be(true) }
        it { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        its('phone_numbers.size') { is_expected.to be(2) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
        its(:historical_values) { are_expected.to be([true, true]) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(subject.one).to be(true)
          is_expected.to be_cool
          expect(subject.phone_numbers.size).to be(2)
          expect(subject.historical_values).to be([true, true])
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  # For single-element array argument, it's possible to make a proper
  # correction for `its`.
  context 'with `its` with single element array syntax' do
    offensive_source = <<-RUBY
      describe do
        its([:one]) { is_expected.to be(true) }
        its(['two']) { is_expected.to be(false) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify do
          expect(subject[:one]).to be(true)
          expect(subject['two']).to be(false)
        end
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end

  # `its` with multi-element array argument is ambiguous, and depends on
  # the type of the subject, and depending on in and on argument passed:
  # - a Hash: `hash[element1][element2]...`
  # - and arbitrary type: `hash[element1, element2, ...]`
  # It is impossible to infer the type to propose a proper correction.
  context 'with `its` with multiple element array syntax' do
    offensive_source = <<-RUBY
      describe do
        its([:one, :two]) { is_expected.to be(true) }
        it { is_expected.to be_cool }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    it 'detects an offense, but does not correct it' do
      expect_offense(offensive_source)
      expect_no_corrections
    end
  end

  # Supports single-element `its` array argument with metadata.
  context 'with `its` with metadata' do
    offensive_source = <<-RUBY
      describe do
        its([:one], night_mode: true) { is_expected.to be(true) }
        its(['two']) { is_expected.to be(false) }
        its(:three, night_mode: true) { is_expected.to be(true) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Aggregate with the example at line 2.
      end
    RUBY

    good_source = <<-RUBY
      describe do
        specify(night_mode: true) do
          expect(subject[:one]).to be(true)
          expect(subject.three).to be(true)
        end
        its(['two']) { is_expected.to be(false) }
      end
    RUBY

    it 'detects and autocorrects' do
      expect_offense(offensive_source)
      expect_correction(good_source)
    end
  end
end
