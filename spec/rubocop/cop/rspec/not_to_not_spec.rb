# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::NotToNot, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is `not_to`' do
    let(:cop_config) { { 'EnforcedStyle' => 'not_to' } }

    it 'detects the `to_not` offense' do
      expect_offense(<<-RUBY)
        it { expect(false).to_not be_true }
                           ^^^^^^ Prefer `not_to` over `to_not`.
      RUBY

      expect_correction(<<-RUBY)
        it { expect(false).not_to be_true }
      RUBY
    end

    it 'detects the `to_not` offense on an expect block' do
      expect_offense(<<-RUBY)
        expect {
          2 + 2
        }.to_not raise_error
          ^^^^^^ Prefer `not_to` over `to_not`.
      RUBY

      expect_correction(<<-RUBY)
        expect {
          2 + 2
        }.not_to raise_error
      RUBY
    end

    it 'detects no offense when using `not_to`' do
      expect_no_offenses(<<-RUBY)
        it { expect(false).not_to be_true }
      RUBY
    end
  end

  context 'when AcceptedMethod is `to_not`' do
    let(:cop_config) { { 'EnforcedStyle' => 'to_not' } }

    it 'detects the `not_to` offense' do
      expect_offense(<<-RUBY)
        it { expect(false).not_to be_true }
                           ^^^^^^ Prefer `to_not` over `not_to`.
      RUBY

      expect_correction(<<-RUBY)
        it { expect(false).to_not be_true }
      RUBY
    end

    it 'detects the `not_to` offense on an expect block' do
      expect_offense(<<-RUBY)
        expect {
          2 + 2
        }.not_to raise_error
          ^^^^^^ Prefer `to_not` over `not_to`.
      RUBY

      expect_correction(<<-RUBY)
        expect {
          2 + 2
        }.to_not raise_error
      RUBY
    end

    it 'detects no offense when using `to_not`' do
      expect_no_offenses(<<-RUBY)
        it { expect(false).to_not be_true }
      RUBY
    end
  end
end
