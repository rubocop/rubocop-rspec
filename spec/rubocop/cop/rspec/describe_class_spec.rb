describe RuboCop::Cop::RSpec::DescribeClass do
  subject(:cop) { described_class.new }

  it 'checks first-line describe statements' do
    inspect_source(cop, 'describe "bad describe" do; end')
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['The first argument to describe should be ' \
                                'the class or module being tested.'])
  end

  it 'checks describe statements after a require' do
    inspect_source(
      cop,
      [
        "require 'spec_helper'",
        'describe "bad describe" do; end'
      ]
    )
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([2])
    expect(cop.messages).to eq(['The first argument to describe should be ' \
                                'the class or module being tested.'])
  end

  it 'ignores nested describe statements' do
    inspect_source(
      cop,
      [
        'describe Some::Class do',
        '  describe "bad describe" do; end',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end

  it 'ignores request specs' do
    inspect_source(cop, "describe 'my new feature', type: :request do; end")
    expect(cop.offenses).to be_empty
  end

  it 'ignores feature specs' do
    inspect_source(cop, "describe 'my new feature', type: :feature do; end")
    expect(cop.offenses).to be_empty
  end

  it 'flags normal metadata in describe' do
    inspect_source(cop, "describe 'my new feature', blah, type: :wow do; end")
    expect(cop.messages).to eq(['The first argument to describe should be ' \
                                'the class or module being tested.'])
  end

  it 'ignores feature specs - also with complex options' do
    inspect_source(
      cop,
      [
        "describe 'my new feature',",
        '  :test, :type => :feature, :foo => :bar do;',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end

  it 'ignores an empty describe' do
    inspect_source(cop, 'describe do; end')
    expect(cop.offenses).to be_empty
  end

  it 'ignores routing specs' do
    inspect_source(cop, "describe 'my new route', type: :routing do; end")
    expect(cop.offenses).to be_empty
  end

  it 'ignores view specs' do
    inspect_source(cop, "describe 'widgets/index', type: :view do; end")
    expect(cop.offenses).to be_empty
  end

  it "doesn't blow up on single-line describes" do
    inspect_source(cop, 'describe Some::Class')
    expect(cop.offenses).to be_empty
  end
end
