# frozen_string_literal: true

RSpec.describe 'config/default.yml' do
  subject(:default_config) do
    RuboCop::ConfigLoader.load_yaml_configuration('config/default.yml')
  end

  let(:namespaces) do
    {
      'rspec' => 'RSpec',
      'capybara' => 'RSpec/Capybara'
    }
  end

  let(:cop_names) do
    glob = SpecHelper::ROOT.join('lib', 'rubocop', 'cop', 'rspec',
                                 '{,capybara}', '*.rb')
    cop_names =
      Pathname.glob(glob).map do |file|
        file_name = file.basename('.rb').to_s
        cop_name  = file_name.gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }
        namespace = namespaces[file.dirname.basename.to_s]
        "#{namespace}/#{cop_name}"
      end

    cop_names - %w[RSpec/Base]
  end

  let(:config_keys) do
    cop_names + namespaces.values
  end

  let(:unsafe_cops) do
    require 'yard'
    YARD::Registry.load!
    YARD::Registry.all(:class).select do |example|
      example.tags.any? { |tag| tag.tag_name == 'safety' }
    end
  end

  let(:unsafe_cop_names) do
    unsafe_cops.map do |cop|
      dept_and_cop_names =
        cop.path.split('::')[2..] # Drop `RuboCop::Cop` from class name.
      dept_and_cop_names.join('/')
    end
  end

  def cop_configuration(config_key)
    cop_names.map do |cop_name|
      cop_config = default_config[cop_name]

      cop_config.fetch(config_key) do
        raise "Expected #{cop_name} to have #{config_key} configuration key"
      end
    end
  end

  it 'has configuration for all cops and amendments' do
    expect(default_config.keys)
      .to contain_exactly(*config_keys, 'Metrics/BlockLength')
  end

  it 'sorts configuration keys alphabetically with nested namespaces last' do
    rspec_keys = default_config.keys.select { |key| key.start_with?('RSpec') }
    namespaced_rspec_keys = rspec_keys.select do |key|
      key.start_with?(*(namespaces.values - ['RSpec']))
    end

    expected = rspec_keys.sort_by do |key|
      namespaced = namespaced_rspec_keys.include?(key) ? 1 : 0
      "#{namespaced} #{key}"
    end

    rspec_keys.each_with_index do |key, idx|
      expect(key).to eq expected[idx]
    end
  end

  it 'has descriptions for all cops' do
    expect(cop_configuration('Description')).to all(be_a(String))
  end

  it 'does not have newlines in cop descriptions' do
    cop_configuration('Description').each do |value|
      expect(value).not_to include("\n")
    end
  end

  it 'ends every description with a period' do
    expect(cop_configuration('Description')).to all(end_with('.'))
  end

  it 'includes a valid Enabled for every cop' do
    expect(cop_configuration('Enabled'))
      .to all be(true).or(be(false)).or(eq('pending'))
  end

  it 'does not include unnecessary `SafeAutoCorrect: false`' do
    cop_names.each do |cop_name|
      next unless default_config.dig(cop_name, 'Safe') == false

      safe_autocorrect = default_config.dig(cop_name, 'SafeAutoCorrect')

      expect(safe_autocorrect).not_to(
        be(false),
        "`#{cop_name}` has unnecessary `SafeAutoCorrect: false` config."
      )
    end
  end

  it 'is expected that all cops documented with `@safety` are `Safe: false` ' \
     'or `SafeAutoCorrect: false`' do
    unsafe_cop_names.each do |cop_name|
      unsafe = default_config[cop_name]['Safe'] == false ||
        default_config[cop_name]['SafeAutoCorrect'] == false
      expect(unsafe).to(
        be(true),
        "`#{cop_name}` cop should be set `Safe: false` or " \
        '`SafeAutoCorrect: false` because `@safety` YARD tag exists.'
      )
      YARD::Registry.clear
    end
  end
end
