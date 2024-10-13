# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Metadata do
  describe '#on_metadata' do
    subject(:on_metadata) do
      stub_class.new.on_metadata(:symbol, {})
    end

    let(:stub_class) do
      Class.new do
        include RuboCop::Cop::RSpec::Metadata
      end
    end

    it { expect { on_metadata }.to raise_error(NotImplementedError) }
  end
end
