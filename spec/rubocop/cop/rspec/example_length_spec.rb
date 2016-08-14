describe RuboCop::Cop::RSpec::ExampleLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 3 } }

  it 'ignores non-spec blocks' do
    inspect_source(
      cop,
      [
        'foo do',
        '  line 1',
        '  line 2',
        '  line 3',
        '  line 4',
        'end'
      ],
      'foo_spec.rb'
    )

    expect(cop.offenses).to be_empty
  end

  it 'allows an empty example' do
    inspect_source(
      cop,
      [
        'it do',
        'end'
      ],
      'foo_spec.rb'
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
      ],
      'spec/foo_spec.rb'
    )
    expect(cop.offenses).to be_empty
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
      ],
      'spec/foo_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  shared_examples 'large example violation' do
    before do
      inspect_source(cop, source, 'spec/foo_spec.rb')
    end

    it 'flags an offense' do
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers the offense on line 1' do
      expect(cop.offenses.map(&:line)).to eq([1])
    end

    it 'adds a message saying the example has too many lines' do
      expect(cop.messages).to eq(['Example has too many lines. [4/3]'])
    end
  end

  context 'when inspecting large examples' do
    let(:source) do
      [
        'it do',
        '  line 1',
        '  line 2',
        '  line 3',
        '  line 4',
        'end'
      ]
    end

    include_examples 'large example violation'
  end

  context 'with CountComments enabled' do
    let(:cop_config) do
      { 'Max' => 3, 'CountComments' => true }
    end

    let(:source) do
      [
        'it do',
        '  line 1',
        '  line 2',
        '  # comment',
        '  line 3',
        'end'
      ]
    end

    include_examples 'large example violation'
  end
end
