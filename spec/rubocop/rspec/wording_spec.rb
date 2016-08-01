xdescribe RuboCop::RSpec::Wording do
  subject { described_class.new() }
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

    {
      'should return something' => 'returns something',
      'should not return something' => 'does not return something',
      'should do nothing' => 'does nothing',
      'should have sweets' => 'has sweets',
      'should worry about the future' => 'worries about the future',
      'should pay for pizza' => 'pays for pizza',
      'should miss me' => 'misses me',
      'should really only return one item' => 'really only returns one item'
    }.each do |old, new|
      it 'autocorrects an offenses' do
        new_source = autocorrect_source(cop, ["it '#{old}' do", 'end'])
        expect(new_source).to eq("it '#{new}' do\nend")
      end
    end

    it "autocorrects shouldn't" do
      new_source = autocorrect_source(
        cop,
        'it "shouldn\'t return something" do; end'
      )
      expect(new_source).to eq('it "does not return something" do; end')
    end

    it 'corrects `it "should have"` to it "has"' do
      corrected = autocorrect_source(cop, 'it "should have trait" do end')
      expect(corrected).to eql('it "has trait" do end')
    end
  end

  context 'when configuration is empty' do
    it 'only corrects the word "should"' do
      corrected = autocorrect_source(cop, 'it "should have trait" do end')
      expect(corrected).to eql('it "haves trait" do end')
    end
  end
end
