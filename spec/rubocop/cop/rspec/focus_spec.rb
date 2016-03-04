# encoding: utf-8

describe RuboCop::Cop::RSpec::Focus do
  subject(:cop) { described_class.new }

  [:describe, :context, :it, :feature, :scenario].each do |block_type|
    it "finds focused `#{block_type}` blocks" do
      inspect_source(cop, ["#{block_type} 'test', focus: true do",
                           'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
      expect(cop.messages).to eq(['Focused spec found.'])
      expect(cop.highlights).to eq(['focus: true'])
    end

    it 'detects no offense when spec is not focused' do
      inspect_source(cop, ["#{block_type} 'test' do",
                           'end'])

      expect(subject.messages).to be_empty
    end
  end
end
