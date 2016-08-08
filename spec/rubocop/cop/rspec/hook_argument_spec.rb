# encoding: utf-8

describe RuboCop::Cop::RSpec::HookArgument do
  subject(:cop) { described_class.new }

  it 'checks `before` hooks' do
    inspect_source(cop, 'before(:each) { true }')

    expect(cop.offenses.size).to eq(1)
  end

  it 'checks `after` hooks' do
    inspect_source(cop, 'after(:each) { true }')

    expect(cop.offenses.size).to eq(1)
  end

  it 'checks `around` hooks' do
    inspect_source(cop, 'around(:each) { |ex| true }')

    expect(cop.offenses.size).to eq(1)
  end

  it 'detects `:each`' do
    inspect_source(cop, 'before(:each) { true }')

    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.highlights).to eq([':each'])
  end

  it 'detects `:example`' do
    inspect_source(cop, 'before(:example) { true }')

    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.highlights).to eq([':example'])
  end

  it 'ignores `:context`' do
    inspect_source(cop, 'before(:context) { true }')

    expect(cop.offenses).to be_empty
  end

  it 'ignores `:suite`' do
    inspect_source(cop, 'before(:suite) { true }')

    expect(cop.offenses).to be_empty
  end
end
