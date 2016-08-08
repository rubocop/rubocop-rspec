# frozen_string_literal: true

describe RuboCop::Cop::RSpec::MessageExpectation, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is allow' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'allow' }
    end

    it 'flags expect(...).to receive' do
      expect_violation(<<-RUBY)
        expect(foo).to receive(:bar)
        ^^^^^^ Prefer `allow` for setting message expectations.
      RUBY
    end

    it 'approves of allow(...).to receive' do
      expect_no_violations('allow(foo).to receive(:bar)')
    end

    it 'generates a todo based on the usage of the correct style' do
      inspect_source(cop, 'allow(foo).to receive(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'allow')
    end

    it 'generates a todo based on the usage of the alternate style' do
      inspect_source(cop, 'expect(foo).to receive(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'expect')
    end

    include_examples 'an rspec only cop'
  end

  context 'when EnforcedStyle is expect' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'expect' }
    end

    it 'flags allow(...).to receive' do
      expect_violation(<<-RUBY)
        allow(foo).to receive(:bar)
        ^^^^^ Prefer `expect` for setting message expectations.
      RUBY
    end

    it 'approves of expect(...).to receive' do
      expect_no_violations('expect(foo).to receive(:bar)')
    end

    it 'generates a todo based on the usage of the correct style' do
      inspect_source(cop, 'expect(foo).to receive(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'expect')
    end

    it 'generates a todo based on the usage of the alternate style' do
      inspect_source(cop, 'allow(foo).to receive(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'allow')
    end

    include_examples 'an rspec only cop'
  end
end
