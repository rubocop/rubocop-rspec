# frozen_string_literal: true

describe RuboCop::Cop::RSpec::MessageSpies, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is have_received' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'have_received' }
    end

    it 'flags expect(...).to receive' do
      expect_violation(<<-RUBY)
        expect(foo).to receive(:bar)
                       ^^^^^^^ Prefer `have_received` for setting message expectations. Setup `foo` as a spy using `allow` or `instance_spy`.
      RUBY
    end

    it 'flags expect(...).to receive with' do
      expect_violation(<<-RUBY)
        expect(foo).to receive(:bar).with(:baz)
                       ^^^^^^^ Prefer `have_received` for setting message expectations. Setup `foo` as a spy using `allow` or `instance_spy`.
      RUBY
    end

    it 'flags expect(...).to receive at_most' do
      expect_violation(<<-RUBY)
        expect(foo).to receive(:bar).at_most(42).times
                       ^^^^^^^ Prefer `have_received` for setting message expectations. Setup `foo` as a spy using `allow` or `instance_spy`.
      RUBY
    end

    it 'approves of expect(...).to have_received' do
      expect_no_violations('expect(foo).to have_received(:bar)')
    end

    it 'generates a todo based on the usage of the correct style' do
      inspect_source(cop, 'expect(foo).to have_received(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses)
        .to eq('EnforcedStyle' => 'have_received')
    end

    it 'generates a todo based on the usage of the alternate style' do
      inspect_source(cop, 'expect(foo).to receive(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'receive')
    end
  end

  context 'when EnforcedStyle is receive' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'receive' }
    end

    it 'flags expect(...).to have_received' do
      expect_violation(<<-RUBY)
        expect(foo).to have_received(:bar)
                       ^^^^^^^^^^^^^ Prefer `receive` for setting message expectations.
      RUBY
    end

    it 'flags expect(...).to have_received with' do
      expect_violation(<<-RUBY)
        expect(foo).to have_received(:bar).with(:baz)
                       ^^^^^^^^^^^^^ Prefer `receive` for setting message expectations.
      RUBY
    end

    it 'flags expect(...).to have_received at_most' do
      expect_violation(<<-RUBY)
        expect(foo).to have_received(:bar).at_most(42).times
                       ^^^^^^^^^^^^^ Prefer `receive` for setting message expectations.
      RUBY
    end

    it 'approves of expect(...).to receive' do
      expect_no_violations('expect(foo).to receive(:bar)')
    end

    it 'generates a todo based on the usage of the correct style' do
      inspect_source(cop, 'expect(foo).to receive(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'receive')
    end

    it 'generates a todo based on the usage of the alternate style' do
      inspect_source(cop, 'expect(foo).to have_received(:bar)', 'foo_spec.rb')

      expect(cop.config_to_allow_offenses)
        .to eq('EnforcedStyle' => 'have_received')
    end
  end
end
