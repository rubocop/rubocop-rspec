# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for matchers that are used in void context.
      #
      # Matcher calls like `change`, `receive`, etc. that appear as
      # standalone expressions have their result silently discarded.
      # This usually means a missing `.and` to chain compound matchers.
      #
      # @example
      #   # bad
      #   specify do
      #     expect { result }.to \
      #       change { obj.foo }.from(1).to(2)
      #       change { obj.bar }.from(3).to(4)
      #   end
      #
      #   # good
      #   specify do
      #     expect { result }.to \
      #       change { obj.foo }.from(1).to(2)
      #       .and change { obj.bar }.from(3).to(4)
      #   end
      #
      #   # good
      #   specify do
      #     expect { result }.to change { obj.foo }.from(1).to(2)
      #   end
      #
      class DiscardedMatcher < Base
        MSG = 'The result of `%<method>s` is not used. ' \
              'Did you mean to chain it with `.and`?'

        MATCHER_METHODS = %i[
          change
          receive
          receive_messages
          receive_message_chain
        ].to_set.freeze

        RESTRICT_ON_SEND = MATCHER_METHODS.freeze

        # @!method matcher_call?(node)
        def_node_matcher :matcher_call?, <<~PATTERN
          (send nil? MATCHER_METHODS ...)
        PATTERN

        def on_send(node)
          return unless matcher_call?(node)
          return unless inside_example?(node)

          target = find_outermost_chain(node)
          return unless void_value?(target)

          add_offense(target, message: format(MSG, method: node.method_name))
        end

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless matcher_call?(node.send_node)
          return unless inside_example?(node)

          target = find_outermost_chain(node)
          return unless void_value?(target)

          add_offense(target, message: format(MSG, method: node.method_name))
        end

        private

        def void_value?(node)
          case node.parent.type
          when :begin
            true
          when :block
            example?(node.parent)
          when :if
            void_value_in_branch?(node, node.parent)
          when :and, :or
            void_in_logical_operator?(node, node.parent)
          when :when, :case
            void_in_case_branch?(node, node.parent)
          end
        end

        def void_value_in_branch?(node, parent)
          (parent.if_branch == node || parent.else_branch == node) &&
            void_value?(parent)
        end

        def void_in_logical_operator?(node, parent)
          parent.rhs == node && void_value?(parent)
        end

        def void_in_case_branch?(node, parent)
          if parent.when_type?
            parent.body == node && void_value?(parent.parent)
          else
            parent.else_branch == node && void_value?(parent)
          end
        end

        def find_outermost_chain(node)
          current = node
          current = current.parent while current.parent.receiver == current
          current
        end

        def inside_example?(node)
          node.each_ancestor(:block).any? { |ancestor| example?(ancestor) }
        end
      end
    end
  end
end
