describe 'config/default.yml' do
  subject(:default_config) do
    RuboCop::ConfigLoader.load_file('config/default.yml')
  end

  let(:cop_names) do
    glob = SpecHelper::ROOT.join('lib', 'rubocop', 'cop', 'rspec', '*.rb')

    Pathname.glob(glob).map do |file|
      file_name = file.basename('.rb').to_s
      cop_name  = file_name.gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }

      "RSpec/#{cop_name}"
    end
  end

  let(:config_keys) do
    cop_names + %w(AllCops)
  end

  it 'has configuration for all cops' do
    expect(default_config.keys.sort).to eq(config_keys.sort)
  end

  it 'has a nicely formatted description for all cops' do
    cop_names.each do |name|
      description = default_config[name]['Description']
      expect(description).not_to be_nil
      expect(description).not_to include("\n")
    end
  end
end
