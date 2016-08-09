require 'rubocop/rspec/config_formatter'

RSpec.describe RuboCop::RSpec::ConfigFormatter do
  let(:config) do
    {
      'AllCops' => {
        'Setting' => 'fourty two'
      },
      'RSpec/Foo' => {
        'Config'      => 2,
        'Enabled'     => true
      },
      'RSpec/Bar' => {
        'Enabled'     => true
      }
    }
  end

  let(:descriptions) do
    {
      'RSpec/Foo' => {
        'Description' => 'Blah'
      },
      'RSpec/Bar' => {
        'Description' => 'Wow'
      }
    }
  end

  it 'builds a YAML dump with spacing between cops' do
    formatter = described_class.new(config, descriptions)

    expect(formatter.dump).to eql(<<-YAML.gsub(/^\s+\|/, ''))
    |---
    |AllCops:
    |  Setting: fourty two
    |
    |RSpec/Foo:
    |  Config: 2
    |  Enabled: true
    |  Description: Blah
    |
    |RSpec/Bar:
    |  Enabled: true
    |  Description: Wow
    YAML
  end
end
