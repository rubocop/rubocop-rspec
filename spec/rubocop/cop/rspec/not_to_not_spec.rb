describe RuboCop::Cop::RSpec::NotToNot, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is `not_to`' do
    let(:cop_config) { { 'EnforcedStyle' => 'not_to' } }

    it 'detects the `to_not` offense' do
      inspect_source(subject, 'it { expect(false).to_not be_true }')

      expect(subject.messages).to eq(['Prefer `not_to` over `to_not`'])
      expect(subject.highlights).to eq(['expect(false).to_not be_true'])
      expect(subject.offenses.map(&:line).sort).to eq([1])
    end

    it 'detects no offense when using `not_to`' do
      inspect_source(subject, 'it { expect(false).not_to be_true }')

      expect(subject.messages).to be_empty
    end

    it 'auto-corrects `to_not` to `not_to`' do
      corrected = autocorrect_source(cop, ['it { expect(0).to_not equal 1 }'])
      expect(corrected).to eq 'it { expect(0).not_to equal 1 }'
    end
  end

  context 'when AcceptedMethod is `to_not`' do
    let(:cop_config) { { 'EnforcedStyle' => 'to_not' } }

    it 'detects the `not_to` offense' do
      inspect_source(subject, 'it { expect(false).not_to be_true }')

      expect(subject.messages).to eq(['Prefer `to_not` over `not_to`'])
      expect(subject.highlights).to eq(['expect(false).not_to be_true'])
      expect(subject.offenses.map(&:line).sort).to eq([1])
    end

    it 'detects no offense when using `to_not`' do
      inspect_source(subject, 'it { expect(false).to_not be_true }')

      expect(subject.messages).to be_empty
    end

    it 'auto-corrects `not_to` to `to_not`' do
      corrected = autocorrect_source(cop, ['it { expect(0).not_to equal 1 }'])
      expect(corrected).to eq 'it { expect(0).to_not equal 1 }'
    end
  end
end
