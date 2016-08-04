# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if an example group does not include any tests
      #
      # @example
      #   # bad
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     context 'extra chunky' do
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
      class EmptyExampleGroup < Cop
        include RuboCop::RSpec::Language

        MSG = 'Empty example group detected.'.freeze

        def_node_matcher :example_group?, <<-PATTERN
          (block
            (send _ {#{ExampleGroups::ALL.to_node_pattern}} ...)
            ...)
        PATTERN

        def_node_search :contains_example?, <<-PATTERN
          (send _ {
            #{Examples::ALL.to_node_pattern}
            :it_behaves_like
            :it_should_behave_like
            :include_context
            :include_examples
          } ...)
        PATTERN

        def on_block(node)
          return unless example_group?(node) && !contains_example?(node)

          add_offense(node.children.first, :expression)
        end
      end
    end
  end
end
