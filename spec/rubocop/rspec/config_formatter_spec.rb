# frozen_string_literal: true

require 'rubocop/rspec/config_formatter'

RSpec.describe RuboCop::RSpec::ConfigFormatter do
  let(:config) do
    {
      'AllCops' => {
        'Setting' => 'forty two'
      },
      'Metrics/BlockLength' => {
        'Exclude' => [
          '**/*_spec.rb',
          '**/spec/**/*'
        ]
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
        'NegatedMatcher' => '~',
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

    expect(formatter.dump).to eql(<<~YAML)
      ---
      AllCops:
        Setting: forty two

      Metrics/BlockLength:
        Exclude:
          - "**/*_spec.rb"
          - "**/spec/**/*"

      RSpec/Foo:
        Config: 2
        Enabled: true
        Description: Blah

      RSpec/Bar:
        Enabled: true
        Nullable: ~
        Description: Wow

      RSpec/Baz:
        Enabled: true
        NegatedMatcher: ~
        StyleGuide: "#buzz"
        Description: Woof
    YAML
  end
end
