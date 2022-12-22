# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for pending or skipped examples without reason.
      #
      # @example
      #   # bad
      #   pending 'does something' do
      #   end
      #
      #   # bad
      #   it 'does something', :pending do
      #   end
      #
      #   # bad
      #   it 'does something' do
      #     pending
      #   end
      #
      #   # bad
      #   xdescribe 'something' do
      #   end
      #
      #   # bad
      #   skip 'does something' do
      #   end
      #
      #   # bad
      #   it 'does something', :skip do
      #   end
      #
      #   # bad
      #   it 'does something' do
      #     skip
      #   end
      #
      #   # bad
      #   it 'does something'
      #
      #   # good
      #   it 'does something' do
      #     pending 'reason'
      #   end
      #
      #   # good
      #   it 'does something' do
      #     skip 'reason'
      #   end
      #
      #   # good
      #   it 'does something', pending: 'reason' do
      #   end
      #
      #   # good
      #   it 'does something', skip: 'reason' do
      #   end
      class PendingWithoutReason < Base
        MSG = 'Give the reason for pending or skip.'

        # @!method pending_by_example_method?(node)
        def_node_matcher :pending_by_example_method?, block_pattern(<<~PATTERN)
          #Examples.pending
        PATTERN

        # @!method pending_by_metadata_without_reason?(node)
        def_node_matcher :pending_by_metadata_without_reason?, <<~PATTERN
          (send #rspec? {#ExampleGroups.all #Examples.all} ... {<(sym :pending) ...> (hash <(pair (sym :pending) true) ...>)})
        PATTERN

        # @!method skipped_by_example_method?(node)
        def_node_matcher :skipped_by_example_method?, block_pattern(<<~PATTERN)
          #Examples.skipped
        PATTERN

        # @!method skipped_by_example_group_method?(node)
        def_node_matcher(
          :skipped_by_example_group_method?,
          block_pattern(<<~PATTERN)
            #ExampleGroups.skipped
          PATTERN
        )

        # @!method skipped_by_metadata_without_reason?(node)
        def_node_matcher :skipped_by_metadata_without_reason?, <<~PATTERN
          (send #rspec? {#ExampleGroups.all #Examples.all} ... {<(sym :skip) ...> (hash <(pair (sym :skip) true) ...>)})
        PATTERN

        # @!method without_reason?(node)
        def_node_matcher :without_reason?, <<~PATTERN
          (send nil? ${:pending :skip})
        PATTERN

        def on_send(node)
          if pending_without_reason?(node)
            add_offense(node, message: 'Give the reason for pending.')
          elsif skipped_without_reason?(node)
            add_offense(node, message: 'Give the reason for skip.')
          elsif without_reason?(node) && example?(node.parent)
            add_offense(node,
                        message: "Give the reason for #{node.method_name}.")
          end
        end

        private

        def pending_without_reason?(node)
          pending_by_example_method?(node.block_node) ||
            pending_by_metadata_without_reason?(node)
        end

        def skipped_without_reason?(node)
          skipped_by_example_group_method?(node.block_node) ||
            skipped_by_example_method?(node.block_node) ||
            skipped_by_metadata_without_reason?(node)
        end
      end
    end
  end
end
