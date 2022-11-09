# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --autocorrect' do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'isolated environment'

  include_context 'when cli spec behavior'

  context 'when corrects `Capybara/CurrentPathExpectation` with ' \
          '`Style/TrailingCommaInArguments`' do
    before do
      RuboCop::ConfigLoader
        .default_configuration
        .for_all_cops['SuggestExtensions'] = false

      create_file('.rubocop.yml', <<~YAML)
        Style/TrailingCommaInArguments:
          EnforcedStyleForMultiline: 'comma'
      YAML

      create_file('spec/example.rb', <<-RUBY)
        expect(page.current_path).to eq(
          some_path(
            id: id
          )
        )
      RUBY
    end

    it 'rubocop terminates with a success' do
      expect(cli.run(['-A', '--only',
                      'Capybara/CurrentPathExpectation,' \
                      'Style/TrailingCommaInArguments'])).to eq(0)
    end

    it 'autocorrects be compatible with each other' do
      cli.run(['-A', '--only',
               'Capybara/CurrentPathExpectation,' \
               'Style/TrailingCommaInArguments'])

      expect(File.read('spec/example.rb')).to eq(<<-RUBY)
        expect(page).to have_current_path(
          some_path(
            id: id,
          ), ignore_query: true
        )
      RUBY
    end
  end
end
