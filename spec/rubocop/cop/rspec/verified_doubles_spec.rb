# encoding: utf-8

describe RuboCop::Cop::RSpec::VerifiedDoubles do
  subject(:cop) { described_class.new }

  it 'finds `double` instead of a verifying double' do
    inspect_source(cop, ['it do',
                         '  foo = double("Widget")',
                         'end'])
    expect(cop.messages)
      .to eq(['Prefer using verifying doubles over normal doubles.'])
    expect(cop.highlights).to eq(['double("Widget")'])
    expect(cop.offenses.map(&:line).sort).to eq([2])
  end
end
