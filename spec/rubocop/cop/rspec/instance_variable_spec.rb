# encoding: utf-8

describe RuboCop::Cop::RSpec::InstanceVariable do
  subject(:cop) { described_class.new }

  it 'finds an instance variable inside a describe' do
    inspect_source(cop, ['describe MyClass do',
                         '  before { @foo = [] }',
                         '  it { expect(@foo).to be_empty }',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([3])
    expect(cop.messages).to eq(['Use `let` instead of an instance variable'])
  end

  it 'finds an instance variable inside a shared example' do
    inspect_source(cop, ["shared_examples 'shared example' do",
                         '  it { expect(@foo).to be_empty }',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([2])
    expect(cop.messages).to eq(['Use `let` instead of an instance variable'])
  end

  it 'ignores an instance variable without describe' do
    inspect_source(cop, ['@foo = []',
                         '@foo.empty?'])
    expect(cop.offenses).to be_empty
  end
end
