# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Base do
  let(:cop_class) { RuboCop::RSpec::FakeCop }
  let(:cop_config) { { 'Exclude' => %w[bar_spec.rb] } }

  before do
    stub_const('RuboCop::RSpec::FakeCop',
               Class.new(described_class) do
                 def on_send(node)
                   add_offense(node, message: 'I flag everything')
                 end
               end)
  end

  context 'when the source path ends with `_spec.rb`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'foo_spec.rb')
        foo(1)
        ^^^^^^ I flag everything
      RUBY
    end

    it 'ignores the file if it is ignored' do
      expect_no_offenses(<<~RUBY, 'bar_spec.rb')
        foo(1)
      RUBY
    end
  end

  context 'when the source path contains `/spec/`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, '/spec/support/thing.rb')
        foo(1)
        ^^^^^^ I flag everything
      RUBY
    end
  end

  context 'when the source path starts with `spec/`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'spec/support/thing.rb')
        foo(1)
        ^^^^^^ I flag everything
      RUBY
    end
  end

  context 'when the file is a source file without "spec" in the name' do
    it 'ignores the source when the path is not a spec file' do
      expect_no_offenses(<<~RUBY, 'foo.rb')
        foo(1)
      RUBY
    end

    it 'ignores the source when the path is not a specified pattern' do
      expect_no_offenses(<<~RUBY, 'foo_test.rb')
        foo(1)
      RUBY
    end
  end

  context 'when custom patterns are specified' do
    let(:other_cops) do
      {
        'RSpec' => {
          'Include' => ['*_test\.rb']
        }
      }
    end

    it 'registers offenses when the path matches a custom specified pattern' do
      expect_offense(<<~RUBY, 'foo_test.rb')
        foo(1)
        ^^^^^^ I flag everything
      RUBY
    end
  end

  describe 'DSL alias configuration' do
    before do
      stub_const('RuboCop::RSpec::ExampleGroupHaterCop',
                 Class.new(described_class) do
                   def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
                     example_group?(node) do
                       add_offense(node, message: 'I flag example groups')
                     end
                   end
                 end)
    end

    let(:cop_class) { RuboCop::RSpec::ExampleGroupHaterCop }

    shared_examples_for 'it detects `describe`' do
      it 'detects `describe` as an example group' do
        expect_offense(<<~RUBY)
          describe 'ouch oh' do
          ^^^^^^^^^^^^^^^^^^^^^ I flag example groups
            it { }
          end
        RUBY
      end
    end

    context 'with the default config' do
      it 'does not detect `epic` as an example group' do
        expect_no_offenses(<<~RUBY)
          epic 'great achievements or events is narrated in elevated style' do
            ballad 'slays Minotaur' do
              # ...
            end
          end
        RUBY
      end

      it_behaves_like 'it detects `describe`'
    end

    context 'when `epic` is set as an alias to example group' do
      before do
        other_cops.dig('RSpec', 'Language', 'ExampleGroups', 'Regular')
          .push('epic')
      end

      it 'detects `epic` as an example group' do
        expect_offense(<<~RUBY)
          epic 'great achievements or events is narrated in elevated style' do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I flag example groups
            ballad 'slays Minotaur' do
              # ...
            end
          end
        RUBY
      end

      it_behaves_like 'it detects `describe`'
    end
  end
end
