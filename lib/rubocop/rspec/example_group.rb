# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec example groups
    class ExampleGroup < Concept
      # @!method scope_change?(node)
      #
      #   Detect if the node is an example group or shared example
      #
      #   Selectors which indicate that we should stop searching
      #
      def_node_matcher :scope_change?, <<~PATTERN
        (block {
          (send #rspec? {#SharedGroups.all #ExampleGroups.all} ...)
          (send nil? #Includes.all ...)
        } ...)
      PATTERN

      def lets
        find_all_in_scope(node, :let?)
      end

      def subjects
        find_all_in_scope(node, :subject?, skip_nested_blocks: true)
      end

      def examples
        find_all_in_scope(node, :example?).map do |node|
          Example.new(node)
        end
      end

      def hooks
        find_all_in_scope(node, :hook?).map do |node|
          Hook.new(node)
        end
      end

      private

      # Recursively search for predicate within the current scope
      #
      # Searches node and halts when a scope change is detected
      #
      # @param node [RuboCop::AST::Node] node to recursively search
      # @param predicate [Symbol] method to call with node as argument
      #
      # @return [Array<RuboCop::AST::Node>] discovered nodes
      def find_all_in_scope(node, predicate, skip_nested_blocks: false)
        node.each_child_node.flat_map do |child|
          find_all(child, predicate, skip_nested_blocks: skip_nested_blocks)
        end
      end

      def find_all(node, predicate, skip_nested_blocks: false)
        return [node] if public_send(predicate, node)
        # No attempt is made to tell an RSpec DSL block from any other: a
        # declaration inside *any* block is not one the group makes
        # unconditionally, so stop rather than identify the block.
        return [] if skip_nested_blocks && node.block_type?
        return [] if scope_change?(node)
        return [] if example?(node)

        find_all_in_scope(
          node,
          predicate,
          skip_nested_blocks: skip_nested_blocks
        )
      end
    end
  end
end
