# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ContainExactly do
  it 'flags `contain_exactly` with only splat arguments' do
    expect_offense(<<-RUBY)
      it { is_expected.to contain_exactly(*array1, *array2) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
      it { is_expected.to contain_exactly(*[1,2,3]) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
      it { is_expected.to contain_exactly(*a.merge(b)) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
      it { is_expected.to contain_exactly(*(a + b)) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
    RUBY

    expect_correction(<<-RUBY)
      it { is_expected.to match_array(array1 + array2) }
      it { is_expected.to match_array([1,2,3]) }
      it { is_expected.to match_array(a.merge(b)) }
      it { is_expected.to match_array((a + b)) }
    RUBY
  end

  it 'flags `contain_exactly` with a splatted percent literal array' do
    expect_offense(<<-RUBY)
      it { is_expected.to contain_exactly(*%w(a b)) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
    RUBY

    expect_correction(<<-RUBY)
      it { is_expected.to match_array(%w(a b)) }
    RUBY
  end

  it 'does not flag `match_array`' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to match_array(array1 + array2) }
    RUBY
  end

  it 'does not flag `contain_exactly` with mixed arguments' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to contain_exactly(content, *array) }
      it { is_expected.to contain_exactly(*array, content) }
    RUBY
  end

  it 'flags `contain_exactly` with no arguments' do
    expect_offense(<<-RUBY)
      it { is_expected.to contain_exactly }
                          ^^^^^^^^^^^^^^^ Prefer `be_empty` when matching an empty collection.
      it { is_expected.to contain_exactly() }
                          ^^^^^^^^^^^^^^^^^ Prefer `be_empty` when matching an empty collection.
    RUBY

    expect_correction(<<-RUBY)
      it { is_expected.to be_empty }
      it { is_expected.to be_empty }
    RUBY
  end
end
