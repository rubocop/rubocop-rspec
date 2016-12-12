# encoding: utf-8

describe RuboCop::Cop::RSpec::BeforeAfterAll do
  subject(:cop) { described_class.new }

  context 'when offenses detected' do
    let(:code) do
      [
        'describe MyClass do',
        '  before(:all) { do_something}',
        '  after(:all) { do_something_else }',
        'end'
      ]
    end

    let(:expected_error) do
      'Avoid the use of before/after(:all) '\
        'as they are not rolled back '\
        'and may lead to database state leaking between examples'
    end

    it 'reports 2 offenses' do
      inspect_source(cop, code, 'foo_spec.rb')
      expect(cop.offenses.size).to eq(2)
    end

    it 'reports the lines for these offenses' do
      inspect_source(cop, code, 'foo_spec.rb')
      expect(cop.offenses.map(&:line).sort).to eq([2, 3])
    end

    it 'describes the offenses' do
      inspect_source(cop, code, 'foo_spec.rb')
      expect(cop.messages).to eq([expected_error, expected_error])
    end
  end

  it 'does not complain for before/after each' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before(:each) { do_something }',
        '  after(:each) { do_something_else }',
        'end'
      ],
      'foo_spec.rb'
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
      ],
      'foo_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end
end
