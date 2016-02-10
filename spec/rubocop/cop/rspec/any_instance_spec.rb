# encoding: utf-8

describe RuboCop::Cop::RSpec::AnyInstance do
  subject(:cop) { described_class.new }

  it 'finds `allow_any_instance_of` instead of an instance double' do
    inspect_source(cop, ['before do',
                         '  allow_any_instance_of(Object).to receive(:foo)',
                         'end'])
    expect(cop.messages)
      .to eq(['Avoid stubbing using `allow_any_instance_of`'])
    expect(cop.highlights).to eq(['allow_any_instance_of(Object)'])
    expect(cop.offenses.map(&:line).sort).to eq([2])
  end

  it 'finds `expect_any_instance_of` instead of an instance double' do
    inspect_source(cop, ['before do',
                         '  expect_any_instance_of(Object).to receive(:foo)',
                         'end'])
    expect(cop.messages)
      .to eq(['Avoid stubbing using `expect_any_instance_of`'])
    expect(cop.highlights).to eq(['expect_any_instance_of(Object)'])
    expect(cop.offenses.map(&:line).sort).to eq([2])
  end

  it 'finds old `any_instance` syntax instead of an instance double' do
    inspect_source(cop, ['before do',
                         '  Object.any_instance.should_receive(:foo)',
                         'end'])
    expect(cop.messages)
      .to eq(['Avoid stubbing using `any_instance`'])
    expect(cop.highlights).to eq(['Object.any_instance'])
    expect(cop.offenses.map(&:line).sort).to eq([2])
  end
end
