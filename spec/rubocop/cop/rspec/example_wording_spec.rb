describe RuboCop::Cop::RSpec::ExampleWording, :config do
  subject(:cop) { described_class.new(config) }

  context 'with configuration' do
    let(:cop_config) do
      {
        'CustomTransform' => { 'have' => 'has', 'not' => 'does not' },
        'IgnoredWords' => %w(only really)
      }
    end

    it 'ignores non-example blocks' do
      inspect_source(cop, 'foo "should do something" do; end')
      expect(cop.offenses).to be_empty
    end

    it 'finds description with `should` at the beginning' do
      inspect_source(cop, ["it 'should do something' do", 'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
      expect(cop.messages)
        .to eq(['Do not use should when describing your tests.'])
      expect(cop.highlights).to eq(['should do something'])
    end

    it 'finds description with `Should` at the beginning' do
      inspect_source(cop, ["it 'Should do something' do", 'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
      expect(cop.messages)
        .to eq(['Do not use should when describing your tests.'])
      expect(cop.highlights).to eq(['Should do something'])
    end

    it 'finds description with `shouldn\'t` at the beginning' do
      inspect_source(cop, ['it "shouldn\'t do something" do', 'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
      expect(cop.messages)
        .to eq(['Do not use should when describing your tests.'])
      expect(cop.highlights).to eq(['shouldn\'t do something'])
    end

    it 'skips descriptions without `should` at the beginning' do
      inspect_source(
        cop,
        [
          "it 'finds no should ' \\",
          "   'here' do",
          'end'
        ]
      )
      expect(cop.offenses).to be_empty
    end

    it 'corrects `it "should only have"` to it "only has"' do
      corrected = autocorrect_source(cop, 'it "should only have trait" do end')
      expect(corrected).to eql('it "only has trait" do end')
    end
  end

  context 'when configuration is empty' do
    it 'only does not correct "have"' do
      corrected = autocorrect_source(cop, 'it "should have trait" do end')
      expect(corrected).to eql('it "haves trait" do end')
    end

    it 'only does not make an exception for the word "only"' do
      corrected = autocorrect_source(cop, 'it "should only fail" do end')
      expect(corrected).to eql('it "onlies fail" do end')
    end
  end
end
