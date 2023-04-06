# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for pending or skipped examples without reason.
      #
      # @example Strict: false (default)
      #   # bad
      #   it 'does something' do
      #     pending
      #   end
      #
      #   # bad
      #   it 'does something', :skip do
      #   end
      #
      #   # good
      #   it 'does something', skip: 'reason' do
      #   end
      #
      #   # good
      #   it 'does something' do
      #     pending 'reason'
      #   end
      #
      #   # also good - when pending/skip block with string argument
      #   pending 'does something' do
      #   end
      #
      #   # also good - when xdescribe block with string argument
      #   xdescribe 'something' do
      #   end
      #
      #   # also good - when pending/skip block with string argument
      #   #             but not inside an example
      #   RSpec.describe 'something' do
      #     pending 'does something'
      #   end
      #
      # @example Strict: true
      #   # bad - when pending/skip block with string argument
      #   pending 'does something' do
      #   end
      #
      #   # bad - when xdescribe block with string argument
      #   xdescribe 'something' do
      #   end
      #
      #   # bad - when pending/skip block with string argument
      #   #       but not inside an example
      #   RSpec.describe 'something' do
      #     pending 'does something'
      #   end
      #
      class PendingWithoutReason < Base
        MSG = 'Give the reason for pending or skip.'

        # @!method skipped_in_example?(node)
        def_node_matcher :skipped_in_example?, <<~PATTERN
          {
            (send nil? ${#Examples.skipped #Examples.pending})
            (block (send nil? ${#Examples.skipped}) ...)
            (numblock (send nil? ${#Examples.skipped}) ...)
          }
        PATTERN

        # @!method skipped_by_example_method_with_block?(node)
        def_node_matcher :skipped_by_example_method_with_block?, <<~PATTERN
          ({block numblock} (send nil? ${#Examples.skipped #Examples.pending} ...) ...)
        PATTERN

        # @!method metadata_without_reason?(node)
        def_node_matcher :metadata_without_reason?, <<~PATTERN
          (send #rspec?
            {#ExampleGroups.all #Examples.all} ...
            {
              <(sym ${:pending :skip}) ...>
              (hash <(pair (sym ${:pending :skip}) true) ...>)
            }
          )
        PATTERN

        # @!method skipped_by_example_group_method?(node)
        def_node_matcher :skipped_by_example_group_method?, <<~PATTERN
          (send #rspec? ${#ExampleGroups.skipped} ...)
        PATTERN

        # @!method pending_step_without_reason?(node)
        def_node_matcher :pending_step_without_reason?, <<~PATTERN
          (send nil? {:skip :pending})
        PATTERN

        def on_send(node)
          on_pending_by_metadata(node)
          return unless (parent = parent_node(node))

          if example_group?(parent) || block_node_example_group?(node)
            on_skipped_by_example_method(node)
            on_skipped_by_example_group_method(node)
          elsif example?(parent)
            on_skipped_by_in_example_method(node)
          end
        end

        private

        def parent_node(node)
          node_or_block = node.block_node || node
          return unless (parent = node_or_block.parent)

          parent.begin_type? && parent.parent ? parent.parent : parent
        end

        def block_node_example_group?(node)
          node.block_node &&
            example_group?(node.block_node) &&
            explicit_rspec?(node.receiver)
        end

        def on_skipped_by_in_example_method(node)
          skipped_in_example?(node) do |pending|
            add_offense(node, message: "Give the reason for #{pending}.")
          end
        end

        def on_pending_by_metadata(node)
          metadata_without_reason?(node) do |pending|
            add_offense(node, message: "Give the reason for #{pending}.")
          end
        end

        def on_skipped_by_example_method(node)
          return unless skipped_or_pending_method?(node.method_name)
          return if (strict? || node.arguments?) && !strict?

          add_offense(node, message: "Give the reason for #{node.method_name}.")
        end

        def on_skipped_by_example_group_method(node)
          return unless strict?

          skipped_by_example_group_method?(node) do
            add_offense(node, message: 'Give the reason for skip.')
          end

          skipped_by_example_method_with_block?(node.parent) do |pending|
            add_offense(node, message: "Give the reason for #{pending}.")
          end
        end

        def skipped_or_pending_method?(method_name)
          Examples.skipped(method_name) || Examples.pending(method_name)
        end

        def strict?
          cop_config.fetch('Strict', true)
        end
      end
    end
  end
end
