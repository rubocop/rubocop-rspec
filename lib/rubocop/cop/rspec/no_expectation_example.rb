# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if an example includes any expectation.
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
        extend AutoCorrector

        include RangeHelp

        MSG = 'No expectation found in this example.'

        # @!method expectation_method_call?(node)
        # @param [RuboCop::AST::Node] node
        # @return [Boolean]
        def_node_matcher(
          :expectation_method_call?,
          send_pattern('#Expectations.all')
        )

        # @param [RuboCop::AST::BlockNode] node
        def on_block(node)
          return unless example_method_call?(node)
          return if including_any_expectation?(node)

          add_offense(node) do |corrector|
            corrector.remove(removed_range(node))
          end
        end

        private

        # @param [RuboCop::AST::BlockNode] node
        # @return [Boolean]
        def example_method_call?(node)
          Examples.all(node.method_name)
        end

        # Recursively checks if the given node includes any expectation.
        # @param [RuboCop::AST::Node] node
        # @return [Boolean]
        def including_any_expectation?(node)
          if !node.is_a?(::RuboCop::AST::Node)
            false
          elsif expectation_method_call?(node)
            true
          else
            node.children.any? do |child|
              including_any_expectation?(child)
            end
          end
        end

        # @param [RuboCop::AST::Node] node
        # @return [Parser::Source::Range]
        def removed_range(node)
          range_by_whole_lines(
            node.location.expression,
            include_final_newline: true
          )
        end
      end
    end
  end
end
