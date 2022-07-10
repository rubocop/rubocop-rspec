# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if an example contains any expectation.
      #
      # All RSpec's example and expectation methods are covered by default.
      # If you are using your own custom methods,
      # add the following configuration:
      #
      #   RSpec:
      #     Language:
      #       Examples:
      #         Regular:
      #           - custom_it
      #       Expectations:
      #         - custom_expect
      #
      # @example
      #
      #   # bad
      #   it do
      #     a?
      #   end
      #
      #   # good
      #   it do
      #     expect(a?).to be(true)
      #   end
      class NoExpectationExample < Base
        MSG = 'No expectation found in this example.'

        # @!method including_any_expectation?(node)
        # @param [RuboCop::AST::Node] node
        # @return [Boolean]
        def_node_search(
          :including_any_expectation?,
          send_pattern('#Expectations.all')
        )

        # @param [RuboCop::AST::BlockNode] node
        def on_block(node)
          return unless example_method_call?(node)
          return if including_any_expectation?(node)

          add_offense(node)
        end

        private

        # @param [RuboCop::AST::BlockNode] node
        # @return [Boolean]
        def example_method_call?(node)
          Examples.all(node.method_name)
        end
      end
    end
  end
end
