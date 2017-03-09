# encoding: utf-8

describe RuboCop::Cop::RSpec::DescribeSymbol do
  subject(:cop) { described_class.new }

  it 'adds an offense for `describe :symbol`' do
    inspect_source(cop, 'describe(:symbol) { }')

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.highlights).to eq([':symbol'])
  end

  it 'handles multiple arguments to `describe`' do
    inspect_source(cop, 'describe(:symbol, "description") { }')

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.highlights).to eq([':symbol'])
  end

  it 'ignores non-Symbol arguments' do
    inspect_source(cop, 'describe(String) { }')

    expect(cop.offenses).to be_empty
  end

  it 'ignores `context :symbol`' do
    inspect_source(cop, 'context(:symbol) { }')

    expect(cop.offenses).to be_empty
  end
end
