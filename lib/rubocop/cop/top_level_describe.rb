# encoding: utf-8

module Rubocop
  module Cop
    # Helper methods for top level describe cops
    module TopLevelDescribe
      def on_send(node)
        return unless top_level_describe?(node)

        _receiver, _method_name, *args = *node
        # Ignore non-string args (RSpec metadata)
        args = [args.first] + args[1..-1].select { |a| a.type == :str }

        on_top_level_describe(node, args)
      end

      private

      def top_level_describe?(node)
        _receiver, method_name, *_args = *node
        return false unless method_name == :describe

        root_node = processed_source.ast
        top_level_nodes = describe_statement_children(root_node)
        # If we have no top level describe statements, we need to check any
        # blocks on the top level (e.g. after a require).
        if top_level_nodes.size == 0
          top_level_nodes = node_children(root_node).map do |child|
            describe_statement_children(child) if child.type == :block
          end.flatten.compact
        end

        top_level_nodes.include? node
      end

      def describe_statement_children(node)
        node_children(node).select do |element|
          element.type == :send && element.children[1] == :describe
        end
      end

      def node_children(node)
        node.children.select { |e| e.is_a? Parser::AST::Node }
      end
    end
  end
end
