# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI run', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'when cli spec behavior'

  context 'when SpecFilePathFormat uses an IgnoreMetadata list' do
    let(:exit_code) do
      cli.run(%w[--format simple --only RSpec/SpecFilePathFormat])
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
            - skip: [database, network]
      YAML
    end

    it 'loads multiple values and array-valued metadata through YAML' do
      create_file('spec/model_spec.rb', <<~RUBY)
        describe MyClass, type: :model do; end
      RUBY
      create_file('spec/routing_spec.rb', <<~RUBY)
        describe MyClass, type: :routing do; end
      RUBY
      create_file('spec/prepare_spec.rb', <<~RUBY)
        describe MyClass, prepare: false do; end
      RUBY
      create_file('spec/database_spec.rb', <<~RUBY)
        describe MyClass, skip: [:database, :network] do; end
      RUBY

      expect(exit_code).to eq(0)
      expect([$stdout.string, $stderr.string]).to match(
        [a_string_including('4 files inspected, no offenses detected'), '']
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

    it 'replaces the default Hash rather than implicitly adding routing' do
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
