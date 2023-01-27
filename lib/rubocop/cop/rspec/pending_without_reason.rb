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
        include InsideExampleGroup
        MSG = 'Give the reason for pending or skip.'

        # @!method skipped_by_example_method?(node)
        def_node_matcher :skipped_by_example_method?, <<~PATTERN
          ({block numblock} (send nil? $#Examples.skipped ...) ...)
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
          {
            #{block_pattern('{#ExampleGroups.skipped}')}
            #{numblock_pattern('{#ExampleGroups.skipped}')}
          }
        PATTERN

        # @!method pending_step_without_reason?(node)
        def_node_matcher :pending_step_without_reason?, <<~PATTERN
          (send nil? {:skip :pending})
        PATTERN

        def on_send(node)
          return unless inside_example_group?(node)

          on_pending_by_metadata(node)
          on_skipped_by_example_method(node)
          on_skipped_by_example_group_method(node)
        end

        def on_block(node)
          return unless inside_example_group?(node)

          on_pending_step(node)
        end
        alias on_numblock on_block

        private

        def on_pending_by_metadata(node)
          metadata_without_reason?(node) do |pending|
            add_offense(node, message: "Give the reason for #{pending}.")
          end
        end

        def on_skipped_by_example_method(node)
          skipped_by_example_method?(node.block_node) do |pending|
            add_offense(node, message: "Give the reason for #{pending}.")
          end
        end

        def on_skipped_by_example_group_method(node)
          skipped_by_example_group_method?(node.block_node) do
            add_offense(node, message: 'Give the reason for skip.')
          end
        end

        def on_pending_step(node)
          block_node_bodys(node).each do |body|
            if pending_step_without_reason?(body)
              add_offense(body,
                          message: "Give the reason for #{body.method_name}.")
            end
          end
        end

        def block_node_bodys(node)
          return [] unless (body = node.body)

          if body.begin_type?
            body.child_nodes
          else
            [body]
          end
        end
      end
    end
  end
end
