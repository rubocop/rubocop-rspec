# encoding: utf-8

describe RuboCop::Cop::RSpec::UnspecifiedValidation do
  subject(:cop) { described_class.new }

  it 'finds valid_for calls' do
    inspect_source(cop, 'it { expect(subject).to be_valid }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Specify field(s) for validation.'])
  end

  it 'finds invalid_for calls' do
    inspect_source(cop, 'it { expect(subject).to be_invalid }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Specify field(s) for validation.'])
  end
end
