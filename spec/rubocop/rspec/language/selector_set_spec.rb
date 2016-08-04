describe RuboCop::RSpec::Language::SelectorSet do
  subject(:selector_set) { described_class.new(%i(foo bar)) }

  it 'composes sets' do
    combined = selector_set + described_class.new(%i(baz))

    expect(combined).to eq(described_class.new(%i(foo bar baz)))
  end

  it 'compares by value' do
    expect(selector_set).not_to eq(described_class.new(%i(foo bar baz)))
  end

  context '#include?' do
    it 'returns false for selectors not in the set' do
      expect(selector_set.include?(:baz)).to be(false)
    end

    it 'returns true for selectors in the set' do
      expect(selector_set.include?(:foo)).to be(true)
    end
  end

  context '#to_node_pattern' do
    it 'builds a node pattern' do
      expect(selector_set.to_node_pattern).to eql(':foo :bar')
    end
  end
end
