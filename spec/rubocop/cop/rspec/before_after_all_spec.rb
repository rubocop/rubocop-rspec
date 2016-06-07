# encoding: utf-8

describe RuboCop::Cop::RSpec::BeforeAfterAll do
  subject(:cop) { described_class.new }

  it 'finds a before/after all' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before(:all) { do_something}',
        '  after(:all) { do_something_else }',
        'end'
      ]
    )
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses.map(&:line).sort).to eq([2, 3])
    expect(cop.messages).to eq([
      'Avoid the use of before/after(:all) to avoid specs flakiness when split out',
      'Avoid the use of before/after(:all) to avoid specs flakiness when split out'
    ])
  end

  it 'does not complain for before/after each' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before(:each) { do_something }',
        '  after(:each) { do_something_else }',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end

  it 'does not complain for before/after' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before { do_something }',
        '  after { do_something_else }',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end
end
