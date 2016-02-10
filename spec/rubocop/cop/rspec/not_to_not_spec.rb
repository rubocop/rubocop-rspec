# encoding: utf-8

describe RuboCop::Cop::RSpec::NotToNot, :config do
  subject(:cop) { described_class.new(config) }

  context 'when AcceptedMethod is `not_to`' do
    let(:cop_config) { { 'AcceptedMethod' => 'not_to' } }

    it 'detects the `to_not` offense' do
      inspect_source(subject, 'it { expect(false).to_not be_true }')

      expect(subject.messages).to eq(['Use `not_to` instead of `to_not`'])
      expect(subject.highlights).to eq(['expect(false).to_not be_true'])
      expect(subject.offenses.map(&:line).sort).to eq([1])
    end

    it 'detects no offense when using `not_to`' do
      inspect_source(subject, 'it { expect(false).not_to be_true }')

      expect(subject.messages).to be_empty
    end
  end

  context 'when AcceptedMethod is `to_not`' do
    let(:cop_config) { { 'AcceptedMethod' => 'to_not' } }

    it 'detects the `not_to` offense' do
      inspect_source(subject, 'it { expect(false).not_to be_true }')

      expect(subject.messages).to eq(['Use `to_not` instead of `not_to`'])
      expect(subject.highlights).to eq(['expect(false).not_to be_true'])
      expect(subject.offenses.map(&:line).sort).to eq([1])
    end

    it 'detects no offense when using `to_not`' do
      inspect_source(subject, 'it { expect(false).to_not be_true }')

      expect(subject.messages).to be_empty
    end
  end
end
