# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI run', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'when cli spec behavior'

  context 'when SpecFilePathFormat uses an IgnoreMetadata list' do
    let(:exit_code) do
      cli.run(%w[--format simple --no-parallel --only RSpec/SpecFilePathFormat])
    end

    before do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: disable
        RSpec/SpecFilePathFormat:
          IgnoreMetadata:
            - prepare
            - type: model
            - type: :routing
      YAML
    end

    it 'loads multiple values and boolean tags through YAML' do
      create_file('spec/model_spec.rb', <<~RUBY)
        describe MyClass, type: :model do; end
      RUBY
      create_file('spec/routing_spec.rb', <<~RUBY)
        describe MyClass, type: :routing do; end
      RUBY
      create_file('spec/prepare_spec.rb', <<~RUBY)
        describe MyClass, prepare: true do; end
      RUBY

      expect(exit_code).to eq(0)
      expect([$stdout.string, $stderr.string]).to match(
        [a_string_including('3 files inspected, no offenses detected'), '']
      )
    end

    it 'reports metadata outside the configured alternatives' do
      create_file('spec/request_spec.rb', <<~RUBY)
        describe MyClass, type: :request do; end
      RUBY

      expect(exit_code).to eq(1)
      expect([$stdout.string, $stderr.string]).to match(
        [a_string_including('1 file inspected, 1 offense detected'), '']
      )
    end

    it 'reports false and String-key tags instead of ignoring them' do
      create_file('spec/false_spec.rb', <<~RUBY)
        describe MyClass, prepare: false do; end
      RUBY
      create_file('spec/string_spec.rb', <<~RUBY)
        describe MyClass, "prepare" => true do; end
      RUBY

      expect(exit_code).to eq(1)
      expect($stdout.string).to include(
        '2 files inspected, 2 offenses detected'
      )
    end

    it 'rejects a multi-pair entry even after a matching tag entry' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: disable
        RSpec/SpecFilePathFormat:
          IgnoreMetadata:
            - prepare
            - type: model
              enabled: true
      YAML
      create_file('spec/prepare_spec.rb', <<~RUBY)
        describe MyClass, :prepare do; end
      RUBY

      expect(exit_code).to eq(2)
      expect($stderr.string).to include(
        'at most one key/value pair', 'Split multiple pairs'
      )
    end

    it 'validates multi-pair entries even without an example group' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: disable
        RSpec/SpecFilePathFormat:
          IgnoreMetadata:
            - type: job
              inline: true
      YAML
      create_file('spec/empty_spec.rb', "# No example groups.\n")

      expect(exit_code).to eq(2)
      expect($stderr.string).to include('Split multiple pairs')
    end

    it 'merges a list with the default routing filter' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: disable
        RSpec/SpecFilePathFormat:
          IgnoreMetadata:
            - type: model
      YAML
      create_file('spec/routing_spec.rb', <<~RUBY)
        describe MyClass, type: :routing do; end
      RUBY
      create_file('spec/model_spec.rb', <<~RUBY)
        describe MyClass, type: :model do; end
      RUBY

      expect(exit_code).to eq(0)
      expect($stdout.string)
        .to include('2 files inspected, no offenses detected')
    end

    it 'merges each pair of a Hash with the default routing filter' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: disable
        RSpec/SpecFilePathFormat:
          IgnoreMetadata:
            type: job
            foo: bar
      YAML
      create_file('spec/routing_spec.rb', <<~RUBY)
        describe MyClass, type: :routing do; end
      RUBY
      create_file('spec/job_spec.rb', <<~RUBY)
        describe MyClass, type: :job do; end
      RUBY
      create_file('spec/foo_spec.rb', <<~RUBY)
        describe MyClass, foo: :bar do; end
      RUBY

      expect(exit_code).to eq(0)
      expect($stdout.string)
        .to include('3 files inspected, no offenses detected')
    end

    it 'drops the default routing filter with `inherit_mode: override`' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: disable
        RSpec/SpecFilePathFormat:
          inherit_mode:
            override:
              - IgnoreMetadata
          IgnoreMetadata:
            - type: model
      YAML
      create_file('spec/routing_spec.rb', <<~RUBY)
        describe MyClass, type: :routing do; end
      RUBY

      expect(exit_code).to eq(1)
      expect($stdout.string).to include('1 file inspected, 1 offense detected')
    end
  end

  context 'when set option `AllowedIdentifiers` for ' \
          '`RSpec/IndexedLet` and `Naming/VariableNumber`' do
    let(:exit_code) do
      cli.run(%w[--format simple --only RSpec/IndexedLet,Naming/VariableNumber])
    end

    it 'does not offense for `RSpec/IndexedLet` ' \
       'when set `AllowedIdentifiers` in `Naming/VariableNumber`' do
      create_file('.rubocop.yml', <<~YAML)
        RSpec/IndexedLet:
          Enabled: true
          AllowedPatterns:
            - foo
        Naming/VariableNumber:
          Enabled: true
          AllowedIdentifiers:
            - bar_1
            - bar_2
      YAML
      create_file('spec/example.rb', <<~RUBY)
        describe SomeService do
          let(:foo_1) { create(:foo) }
          let(:foo_2) { create(:foo) }
          let(:bar_1) { create(:bar) }
          let(:bar_2) { create(:bar) }
          let(:baz_1) { create(:baz) }
          let(:baz_2) { create(:baz) }
        end
      RUBY
      expect(exit_code).to eq(1)
      expect($stdout.string).to eq(<<~OUTPUT)
        == spec/example.rb ==
        C:  2:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  3:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  6:  3: RSpec/IndexedLet: This let statement uses 1 in its name. Please give it a meaningful name.
        C:  6:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  7:  3: RSpec/IndexedLet: This let statement uses 2 in its name. Please give it a meaningful name.
        C:  7:  7: Naming/VariableNumber: Use normalcase for symbol numbers.

        1 file inspected, 6 offenses detected
      OUTPUT
    end
  end

  context 'when set option `AllowedPatterns` for ' \
          '`RSpec/IndexedLet` and `Naming/VariableNumber`' do
    let(:exit_code) do
      cli.run(%w[--format simple --only RSpec/IndexedLet,Naming/VariableNumber])
    end

    it 'does not offense for `RSpec/IndexedLet` ' \
       'when set `AllowedPatterns` in `Naming/VariableNumber`' do
      create_file('.rubocop.yml', <<~YAML)
        RSpec/IndexedLet:
          Enabled: true
          AllowedPatterns:
            - foo
        Naming/VariableNumber:
          Enabled: true
          AllowedPatterns:
            - bar
      YAML
      create_file('spec/example.rb', <<~RUBY)
        describe SomeService do
          let(:foo_1) { create(:foo) }
          let(:foo_2) { create(:foo) }
          let(:bar_1) { create(:bar) }
          let(:bar_2) { create(:bar) }
          let(:baz_1) { create(:baz) }
          let(:baz_2) { create(:baz) }
        end
      RUBY
      expect(exit_code).to eq(1)
      expect($stdout.string).to eq(<<~OUTPUT)
        == spec/example.rb ==
        C:  2:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  3:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  6:  3: RSpec/IndexedLet: This let statement uses 1 in its name. Please give it a meaningful name.
        C:  6:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  7:  3: RSpec/IndexedLet: This let statement uses 2 in its name. Please give it a meaningful name.
        C:  7:  7: Naming/VariableNumber: Use normalcase for symbol numbers.

        1 file inspected, 6 offenses detected
      OUTPUT
    end
  end
end
