# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::Inject do
  describe '.defaults!' do
    let(:config_loader) { class_double(RuboCop::ConfigLoader).as_stubbed_const }

    before do
      rubocop_config = instance_double(RuboCop::Config)
      allow(config_loader).to receive(:send)
        .with(:load_yaml_configuration, any_args)
        .and_return({})
      allow(RuboCop::Config).to receive(:new).and_return(rubocop_config)
      allow(config_loader).to receive(:merge_with_default)
        .and_return(rubocop_config)
      allow(config_loader).to receive(:instance_variable_set)
    end

    context 'when ConfigLoader.debug? is true' do
      before do
        allow(config_loader).to receive(:debug?).and_return(true)
      end

      it 'puts the configuration path' do
        expect { described_class.defaults! }.to output(
          %r{configuration from .*rubocop-rspec/config/default.yml}
        ).to_stdout
      end
    end

    context 'when ConfigLoader.debug? is false' do
      before do
        allow(config_loader).to receive(:debug?).and_return(false)
      end

      it 'does not put the configuration path' do
        expect { described_class.defaults! }.not_to output.to_stdout
      end
    end
  end
end
