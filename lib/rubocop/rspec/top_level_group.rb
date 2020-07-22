# frozen_string_literal: true

module RuboCop
  module RSpec
    # Helper methods for top level example group cops
    module TopLevelGroup
      extend RuboCop::NodePattern::Macros
      include RuboCop::RSpec::Language

      def_node_matcher :example_or_shared_group?,
                       (ExampleGroups::ALL + SharedGroups::ALL).block_pattern

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
        @top_level_groups ||=
          top_level_nodes(root_node).select { |n| example_or_shared_group?(n) }
      end

      def top_level_nodes(node)
        if node.begin_type?
          node.children
        elsif node.module_type? || node.class_type?
          top_level_nodes(node.body)
        else
          [node]
        end
      end

      def root_node
        processed_source.ast
      end
    end
  end
end
