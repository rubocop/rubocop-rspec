# frozen_string_literal: true

require 'rubocop/rspec/config_formatter'

RSpec.describe RuboCop::RSpec::ConfigFormatter do
  let(:config) do
    {
      'AllCops' => {
        'Setting' => 'forty two'
      },
      'RSpec/Foo' => {
        'Config' => 2,
        'Enabled' => true
      },
      'RSpec/Bar' => {
        'Enabled' => true,
        'Nullable' => nil
      },
      'RSpec/Baz' => {
        'Enabled' => true,
        'StyleGuide' => '#buzz'
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
      },
      'RSpec/Baz' => {
        'Description' => 'Woof'
      }
    }
  end

  it 'builds a YAML dump with spacing between cops' do
    formatter = described_class.new(config, descriptions)

    expect(formatter.dump).to eql(<<-YAML.gsub(/^\s+\|/, ''))
      |---
      |AllCops:
      |  Setting: forty two
      |
      |RSpec/Foo:
      |  Config: 2
      |  Enabled: true
      |  Description: Blah
      |  Reference: https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Foo
      |
      |RSpec/Bar:
      |  Enabled: true
      |  Nullable: ~
      |  Description: Wow
      |  Reference: https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Bar
      |
      |RSpec/Baz:
      |  Enabled: true
      |  StyleGuide: "#buzz"
      |  Description: Woof
      |  Reference: https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/Baz
    YAML
  end
end
