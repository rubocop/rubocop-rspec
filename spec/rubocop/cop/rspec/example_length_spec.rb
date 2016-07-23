describe RuboCop::Cop::RSpec::ExampleLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 3 } }

  it 'allows an empty example' do
    inspect_source(
      cop,
      [
        'it do',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows a short example' do
    inspect_source(
      cop,
      [
        'it do',
        '  line 1',
        '  line 2',
        '  line 3',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end

  it 'doesn\t allow a long example' do
    inspect_source(
      cop,
      [
        'it do',
        '  line 1',
        '  line 2',
        '  line 3',
        '  line 4',
        'end'
      ]
    )
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Example has too many lines. [4/3]'])
  end

  it 'ignores comments' do
    inspect_source(
      cop,
      [
        'it do',
        '  line 1',
        '  line 2',
        '  # comment',
        '  line 3',
        'end'
      ]
    )
    expect(cop.offenses).to be_empty
  end

  context 'with CountComments enabled' do
    before { cop_config['CountComments'] = true }

    it 'counts comments' do
      inspect_source(
        cop, [
          'it do',
          '  line 1',
          '  line 2',
          '  # comment',
          '  line 3',
          'end'
        ]
      )
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
      expect(cop.messages).to eq(['Example has too many lines. [4/3]'])
    end
  end
end
