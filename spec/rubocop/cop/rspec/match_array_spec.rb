# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MatchArray do
  it 'flags `match_array` with array literal arguments' do
    expect_offense(<<-RUBY)
      it { is_expected.to match_array([content1, content2]) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `contain_exactly` when matching an array literal.
    RUBY

    expect_correction(<<-RUBY)
      it { is_expected.to contain_exactly(content1, content2) }
    RUBY
  end

  it 'does not flag `contain_exactly`' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to contain_exactly(content1, content2) }
    RUBY
  end

  it 'does not flag `match_array` with mixed arguments' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to match_array([content] + array) }
    RUBY
  end

  it 'does not flag `match_array` with a percent array' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to match_array(%w(tremble in fear foolish mortals)) }
      it { is_expected.to match_array(%i(foo bar baz)) }
    RUBY
  end
end
