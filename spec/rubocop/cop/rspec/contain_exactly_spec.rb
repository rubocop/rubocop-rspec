# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ContainExactly do
  it 'flags `contain_exactly` with a single splat argument' do
    expect_offense(<<~RUBY)
      it { is_expected.to contain_exactly(*[1,2,3]) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
      it { is_expected.to contain_exactly(*a.merge(b)) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
      it { is_expected.to contain_exactly(*(a + b)) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
    RUBY

    expect_correction(<<~RUBY)
      it { is_expected.to match_array([1,2,3]) }
      it { is_expected.to match_array(a.merge(b)) }
      it { is_expected.to match_array((a + b)) }
    RUBY
  end

  it 'flags `contain_exactly` with a splatted percent literal array' do
    expect_offense(<<~RUBY)
      it { is_expected.to contain_exactly(*%w(a b)) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
    RUBY

    expect_correction(<<~RUBY)
      it { is_expected.to match_array(%w(a b)) }
    RUBY
  end

  it 'does not flag `match_array`' do
    expect_no_offenses(<<~RUBY)
      it { is_expected.to match_array(array1 + array2) }
    RUBY
  end

  it 'does not flag `contain_exactly` with mixed arguments' do
    expect_no_offenses(<<~RUBY)
      it { is_expected.to contain_exactly(content, *array) }
      it { is_expected.to contain_exactly(*array, content) }
    RUBY
  end

  it 'does not flag `contain_exactly` with multiple splat arguments' do
    expect_no_offenses(<<~RUBY)
      it { is_expected.to contain_exactly(*array1, *array2) }
      it { is_expected.to contain_exactly(*0..9, *100..109, *200..209) }
    RUBY
  end

  # Don't do the work of RSpec/BeEmpty
  it 'does not flag `contain_exactly` with no arguments' do
    expect_no_offenses(<<~RUBY)
      it { is_expected.to contain_exactly }
      it { is_expected.to contain_exactly() }
    RUBY
  end

  it 'does not crash when the splat arg is itself a `contain_exactly` call' do
    expect_offense(<<~RUBY)
      RSpec.describe Basket do
        subject { basket.contents }

        it 'matches, however contrived the nesting' do
          array = [1, 2, 3]
          expect(subject).to contain_exactly(*contain_exactly(*array))
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
                                              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe Basket do
        subject { basket.contents }

        it 'matches, however contrived the nesting' do
          array = [1, 2, 3]
          expect(subject).to match_array(match_array(array))
        end
      end
    RUBY
  end
end
