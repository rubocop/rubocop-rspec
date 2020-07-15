# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if an example group does not include any tests.
      #
      # This cop is configurable using the `CustomIncludeMethods` option
      #
      # @example usage
      #
      #   # bad
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     context 'extra chunky' do   # flagged by rubocop
      #       let(:chunkiness) { true }
      #     end
      #
      #     it 'is chunky' do
      #       expect(bacon.chunky?).to be_truthy
      #     end
      #   end
      #
      #   # good
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     it 'is chunky' do
      #       expect(bacon.chunky?).to be_truthy
      #     end
      #   end
      #
      # @example configuration
      #
      #   # .rubocop.yml
      #   # RSpec/EmptyExampleGroup:
      #   #   CustomIncludeMethods:
      #   #   - include_tests
      #
      #   # spec_helper.rb
      #   RSpec.configure do |config|
      #     config.alias_it_behaves_like_to(:include_tests)
      #   end
      #
      #   # bacon_spec.rb
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     context 'extra chunky' do   # not flagged by rubocop
      #       let(:chunkiness) { true }
      #
      #       include_tests 'shared tests'
      #     end
      #   end
      #
      class EmptyExampleGroup < Base
        MSG = 'Empty example group detected.'

        def_node_matcher :example_group_body, <<~PATTERN
          (block #{ExampleGroups::ALL.send_pattern} args $_)
        PATTERN

        def_node_matcher :example_or_group_or_include?, <<~PATTERN
          {
            #{Examples::ALL.block_pattern}
            #{ExampleGroups::ALL.block_pattern}
            #{Includes::ALL.send_pattern}
            (send nil? #custom_include? ...)
          }
        PATTERN

        def_node_matcher :examples_in_iterator?, <<~PATTERN
          (block
            {
              (send _ :each)
              (send _ :each_with_object _)
              (send _ :each_with_index)
              (send (send _ :each) :with_object _)
              (send (send _ :each) :with_index)
            }
            _ #examples?
          )
        PATTERN

        def_node_matcher :examples_directly_or_in_iterator?, <<~PATTERN
          {
            #example_or_group_or_include?
            #examples_in_iterator?
          }
        PATTERN

        def_node_matcher :examples?, <<~PATTERN
          {
            #examples_directly_or_in_iterator?
            (begin <#examples_directly_or_in_iterator? ...>)
          }
        PATTERN

        def on_block(node)
          example_group_body(node) do |body|
            add_offense(node.send_node) unless examples?(body)
          end
        end

        private

        def custom_include?(method_name)
          custom_include_methods.include?(method_name)
        end

        def custom_include_methods
          cop_config
            .fetch('CustomIncludeMethods', [])
            .map(&:to_sym)
        end
      end
    end
  end
end
