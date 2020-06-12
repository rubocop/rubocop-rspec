# frozen_string_literal: true

module RuboCop
  module RSpec
    # Helper methods for top level example group cops
    module TopLevelGroup
      def on_block(node)
        return unless respond_to?(:on_top_level_group)
        return unless top_level_group?(node)

        on_top_level_group(node)
      end

      private

      def top_level_group?(node)
        top_level_groups.include?(node)
      end

      def top_level_groups
        @top_level_groups ||= top_level_nodes.select { |n| example_group?(n) }
      end

      def top_level_nodes
        @top_level_nodes ||= \
          if root_node.begin_type?
            root_node.children
          else
            [root_node]
          end
      end

      def root_node
        processed_source.ast
      end
    end
  end
end
