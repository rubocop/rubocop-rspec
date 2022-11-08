# frozen_string_literal: true

RSpec.describe 'Project requires' do
  shared_examples 'alphabetizes cop requires' do
    it 'alphabetizes cop requires' do
      captures = source.read.scan(%r{^(require_relative '(.*?/)?(.*?)')$})

      require_statements = captures.map(&:first)
      sorted_require_statements =
        captures.sort_by do |_require_statement, cop_category, name|
          [cop_category || 'rspec', name]
        end.map(&:first)

      aggregate_failures do
        # Sanity check that we actually discovered require statements.
        expect(captures).not_to be_empty
        expect(require_statements).to eql(sorted_require_statements)
      end
    end
  end

  it_behaves_like 'alphabetizes cop requires' do
    let(:source) { SpecHelper::ROOT.join('lib', 'rubocop', 'cop', 'capybara', 'cops.rb') }
  end

  it_behaves_like 'alphabetizes cop requires' do
    let(:source) { SpecHelper::ROOT.join('lib', 'rubocop', 'cop', 'factory_bot', 'cops.rb') }
  end

  it_behaves_like 'alphabetizes cop requires' do
    let(:source) { SpecHelper::ROOT.join('lib', 'rubocop', 'cop', 'rspec', 'cops.rb') }
  end

  it_behaves_like 'alphabetizes cop requires' do
    let(:source) { SpecHelper::ROOT.join('lib', 'rubocop', 'cop', 'rspec-rails', 'cops.rb') }
  end
end
