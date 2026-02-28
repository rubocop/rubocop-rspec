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
      # The list of matcher methods can be configured
      # with `CustomMatcherMethods`.
      #
      # @example
      #   # bad
      #   specify do
      #     expect { result }
      #       .to change { obj.foo }.from(1).to(2)
      #       change { obj.bar }.from(3).to(4)
      #   end
      #
      #   # good
      #   specify do
      #     expect { result }
      #       .to change { obj.foo }.from(1).to(2)
      #       .and change { obj.bar }.from(3).to(4)
      #   end
      #
      #   # good
      #   specify do
      #     expect { result }.to change { obj.foo }.from(1).to(2)
      #   end
      #
      class DiscardedMatcher < Base
        include InsideExample

        MSG = 'The result of `%<method>s` is not used. ' \
              'Did you mean to chain it with `.and`?'

        MATCHER_METHODS = %i[
          change have_received output
          receive receive_messages receive_message_chain
        ].to_set.freeze

        def on_send(node)
          check_discarded_matcher(node, node)
        end

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          check_discarded_matcher(node.send_node, node)
        end

        private

        def check_discarded_matcher(send_node, node)
          return unless matcher_call?(send_node)
          return unless inside_example?(node)
          return unless example_with_matcher_expectation?(node)

          target = find_outermost_chain(node)
          return unless void_value?(target)

          add_offense(target, message: format(MSG, method: node.method_name))
        end

        def example_with_matcher_expectation?(node)
          example_node =
            node.each_ancestor(:block).find { |ancestor| example?(ancestor) }

          example_node.each_descendant(:send).any? do |send_node|
            expectation_with_matcher?(send_node)
          end
        end

        def expectation_with_matcher?(node)
          %i[to to_not not_to].include?(node.method_name) &&
            node.arguments.any? do |arg|
              arg.each_node(:send).any? { |s| matcher_call?(s) }
            end
        end

        def void_value?(node)
          case node.parent.type
          when :block
            example?(node.parent)
          when :begin, :case, :when
            void_value?(node.parent)
          end
        end

        def matcher_call?(node)
          node.receiver.nil? && all_matcher_methods.include?(node.method_name)
        end

        def all_matcher_methods
          @all_matcher_methods ||=
            (MATCHER_METHODS + custom_matcher_methods).freeze
        end

        def custom_matcher_methods
          cop_config.fetch('CustomMatcherMethods', []).map(&:to_sym)
        end

        def find_outermost_chain(node)
          current = node
          current = current.parent while current.parent.receiver == current
          current
        end
      end
    end
  end
end
