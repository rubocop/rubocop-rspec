# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --autocorrect' do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'isolated environment'

  include_context 'when cli spec behavior'

  context 'when corrects `RSpec/AlignLeftLetBrace` and ' \
          '`RSpec/AlignRightLetBrace` with `Layout/ExtraSpacing`' do
    before do
      RuboCop::ConfigLoader
        .default_configuration
        .for_all_cops['SuggestExtensions'] = false

      create_file('.rubocop.yml', <<~YAML)
        RSpec/AlignLeftLetBrace:
          Enabled: true
        RSpec/AlignRightLetBrace:
          Enabled: true
      YAML

      create_file('spec/example.rb', <<~RUBY)
        let(:foobar) { blahblah }
        let(:baz) { bar }
        let(:a) { b }
      RUBY
    end

    it 'rubocop terminates with a success' do
      expect(cli.run(['-A', '--only',
                      'RSpec/AlignLeftLetBrace,' \
                      'RSpec/AlignRightLetBrace,' \
                      'Layout/ExtraSpacing'])).to eq(0)
    end

    it 'autocorrects be compatible with each other' do
      cli.run(['-A', '--only',
               'RSpec/AlignLeftLetBrace,' \
               'RSpec/AlignRightLetBrace,' \
               'Layout/ExtraSpacing'])

      expect(File.read('spec/example.rb')).to eq(<<~RUBY)
        let(:foobar) { blahblah }
        let(:baz)    { bar      }
        let(:a)      { b        }
      RUBY
    end
  end

  context 'when corrects `RSpec/LetBeforeExamples` with ' \
          '`RSpec/ScatteredLet`' do
    before do
      RuboCop::ConfigLoader
        .default_configuration
        .for_all_cops['SuggestExtensions'] = false

      create_file('spec/example.rb', <<~RUBY)
        RSpec.describe 'Foo' do
          let(:params) { {} }

          specify do
            expect(true).to be true
          end

          let(:attributes) { %i[first_name last_name] }
        end
      RUBY
    end

    it 'rubocop terminates with a success' do
      expect(cli.run(['-A', '--only',
                      'RSpec/LetBeforeExamples,' \
                      'RSpec/ScatteredLet'])).to eq(0)
    end

    it 'autocorrects be compatible with each other' do
      cli.run(['-A', '--only',
               'RSpec/LetBeforeExamples,' \
               'RSpec/ScatteredLet'])

      expect(File.read('spec/example.rb')).to eq(<<~RUBY)
        RSpec.describe 'Foo' do
          let(:params) { {} }

          let(:attributes) { %i[first_name last_name] }
          specify do
            expect(true).to be true
          end

        end
      RUBY
    end
  end
end
