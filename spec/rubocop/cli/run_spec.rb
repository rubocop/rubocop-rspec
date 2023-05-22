# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI run', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'when cli spec behavior'

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
        C:  6:  3: RSpec/IndexedLet: This let statement uses index in its name. Please give it a meaningful name.
        C:  6:  7: Naming/VariableNumber: Use normalcase for symbol numbers.
        C:  7:  3: RSpec/IndexedLet: This let statement uses index in its name. Please give it a meaningful name.
        C:  7:  7: Naming/VariableNumber: Use normalcase for symbol numbers.

        1 file inspected, 6 offenses detected
      OUTPUT
    end
  end
end
