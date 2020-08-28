# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that the first argument to an example group is not empty.
      #
      # @example
      #   # bad
      #   describe do
      #   end
      #
      #   RSpec.describe do
      #   end
      #
      #   # good
      #   describe TestedClass do
      #   end
      #
      #   describe "A feature example" do
      #   end
      #
      #   context do
      #     include_context 'when something is different'
      #   end
      class MissingExampleGroupArgument < Base
        MSG = 'The first argument to `%<method>s` should not be empty.'
        INCLUDE_CONTEXT = '(send nil? :include_context str)'

        def_node_matcher :context_with_shared_context?, <<~PATTERN
          (block (send nil? :context) _ {
            (begin #{INCLUDE_CONTEXT} ...)
            #{INCLUDE_CONTEXT}
          })
        PATTERN

        def on_block(node)
          return unless example_group?(node)
          return if node.send_node.arguments?
          return if context_with_shared_context?(node)

          add_offense(node, message: format(MSG, method: node.method_name))
        end
      end
    end
  end
end
