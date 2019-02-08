# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ImplicitExpect, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is is_expected' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'is_expected' }
    end

    it 'flags it { should }' do
      expect_offense(<<-RUBY)
        it { should be_truthy }
             ^^^^^^ Prefer `is_expected.to` over `should`.
      RUBY

      expect_correction(<<-RUBY)
        it { is_expected.to be_truthy }
      RUBY
    end

    it 'flags it { should_not }' do
      expect_offense(<<-RUBY)
        it { should_not be_truthy }
             ^^^^^^^^^^ Prefer `is_expected.to_not` over `should_not`.
      RUBY

      expect_correction(<<-RUBY)
        it { is_expected.to_not be_truthy }
      RUBY
    end

    it 'approves of is_expected.to' do
      expect_no_offenses('it { is_expected.to be_truthy }')
    end

    it 'approves of is_expected.to_not' do
      expect_no_offenses('it { is_expected.to_not be_truthy }')
    end

    it 'approves of is_expected.not_to' do
      expect_no_offenses('it { is_expected.not_to be_truthy }')
    end

    include_examples 'detects style', 'it { should be_truthy }', 'should'
  end

  context 'when EnforcedStyle is should' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'should' }
    end

    it 'flags it { is_expected.to }' do
      expect_offense(<<-RUBY)
        it { is_expected.to be_truthy }
             ^^^^^^^^^^^^^^ Prefer `should` over `is_expected.to`.
      RUBY

      expect_correction(<<-RUBY)
        it { should be_truthy }
      RUBY
    end

    it 'flags it { is_expected.to_not }' do
      expect_offense(<<-RUBY)
        it { is_expected.to_not be_truthy }
             ^^^^^^^^^^^^^^^^^^ Prefer `should_not` over `is_expected.to_not`.
      RUBY

      expect_correction(<<-RUBY)
        it { should_not be_truthy }
      RUBY
    end

    it 'flags it { is_expected.not_to }' do
      expect_offense(<<-RUBY)
        it { is_expected.not_to be_truthy }
             ^^^^^^^^^^^^^^^^^^ Prefer `should_not` over `is_expected.not_to`.
      RUBY

      expect_correction(<<-RUBY)
        it { should_not be_truthy }
      RUBY
    end

    it 'approves of should' do
      expect_no_offenses('it { should be_truthy }')
    end

    it 'approves of should_not' do
      expect_no_offenses('it { should_not be_truthy }')
    end

    include_examples 'detects style',
                     'it { is_expected.to be_truthy }',
                     'is_expected'

    include_examples 'detects style',
                     'it { should be_truthy }',
                     'should'
  end
end
