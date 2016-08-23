# encoding: utf-8

describe RuboCop::Cop::RSpec::Predicate, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is boolean' do
    let(:cop_config) { { 'EnforcedStyle' => 'equality' } }

    TESTS = {
      'expect(foo.bar).to be_valid' =>
        'expect(foo.bar.valid?).to eq(true)',
      'expect({ foo: :bar }).to have_key(:foo)' =>
        'expect({ foo: :bar }.key?(:foo)).to eq(true)',
      'expect({ foo: :bar }).to have_attributes(:foo, :baz)' =>
        'expect({ foo: :bar }.has_attributes?(:foo, :baz)).to eq(true)',
      'expect([]).to respond_to(:foo)' =>
        'expect([].respond_to?(:foo)).to eq(true)',
      'expect([]).not_to be_a(Array)' =>
        'expect([].is_a?(Array)).to eq(false)',
      'expect([:foo]).to include(:foo)' =>
        'expect([:foo].include?(:foo)).to eq(true)'
    }.freeze

    TESTS.each do |offense, suggestion|
      it "flags `#{offense}`" do
        inspect_source(cop, offense)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([offense])

        message = "Use predicate matcher `#{suggestion}`"
        expect(cop.messages).to eq([message])
      end
    end
  end

  context 'when EnforcedStyle is truthiness' do
    let(:cop_config) { { 'EnforcedStyle' => 'truthiness' } }

    TESTS = {
      'expect(foo.bar).to be_valid' =>
        'expect(foo.bar.valid?).to be_truthy',
      'expect({ foo: :bar }).to have_key(:foo)' =>
        'expect({ foo: :bar }.key?(:foo)).to be_truthy',
      'expect({ foo: :bar }).to have_attributes(:foo, :baz)' =>
        'expect({ foo: :bar }.has_attributes?(:foo, :baz)).to be_truthy',
      'expect([]).to respond_to(:foo)' =>
        'expect([].respond_to?(:foo)).to be_truthy',
      'expect([]).not_to be_a(Array)' =>
        'expect([].is_a?(Array)).to be_falsey',
      'expect([:foo]).to include(:foo)' =>
        'expect([:foo].include?(:foo)).to be_truthy'
    }.freeze

    TESTS.each do |offense, suggestion|
      it "flags `#{offense}`" do
        inspect_source(cop, offense)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([offense])

        message = "Use predicate matcher `#{suggestion}`"
        expect(cop.messages).to eq([message])
      end
    end
  end

  context 'when EnforcedStyle is predicate' do
    let(:cop_config) { { 'EnforcedStyle' => 'predicate' } }

    TESTS = {
      'expect(foo.bar.valid?).to eq(true)' =>
        'expect(foo.bar).to be_valid',
      'expect({ foo: :bar }.has_key?(:foo)).to eq(true)' =>
        'expect({ foo: :bar }).to have_key(:foo)',
      'expect({ foo: :bar }.key?(:foo)).to eq(true)' =>
        'expect({ foo: :bar }).to have_key(:foo)',
      'expect({ foo: :bar }.has_attributes?(:foo, :baz)).to eq(true)' =>
        'expect({ foo: :bar }).to have_attributes(:foo, :baz)',
      'expect([].respond_to?(:foo)).to eq(true)' =>
        'expect([]).to respond_to(:foo)',
      'expect([].is_a?(Array)).to eq(true)' =>
        'expect([]).to be_a(Array)',
      'expect([:foo].include?(:foo)).to eq(true)' =>
        'expect([:foo]).to include(:foo)'
    }.freeze

    TESTS.each do |offense, suggestion|
      it "flags `#{offense}`" do
        inspect_source(cop, offense)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([offense])

        message = "Use predicate matcher `#{suggestion}`"
        expect(cop.messages).to eq([message])
      end
    end

    it 'does not flags truthiness' do
      inspect_source(cop, 'expect(foo.bar.valid?).to be_truthy')

      expect(cop.offenses.size).to eq(0)
    end

    it 'autocorrects an offense' do
      replacement = autocorrect_source(cop, ['expect(foo.valid?).to eq(true)'])
      expect(replacement).to eq('expect(foo).to be_valid')
    end

    it 'autocorrects falsey offense' do
      replacement = autocorrect_source(cop, ['expect(foo.valid?).to eq(false)'])
      expect(replacement).to eq('expect(foo).not_to be_valid')
    end
  end
end
