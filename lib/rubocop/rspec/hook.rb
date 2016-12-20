# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec hook
    class Hook
      extend RuboCop::NodePattern::Macros

      def initialize(node)
        @node = node
      end

      def name
        node.method_name
      end

      def scope
        scope_argument ? scope_argument.to_a.first : :each
      end

      def unknown_scope?
        return false unless scope_argument

        !scope_argument.sym_type?
      end

      def to_node
        node
      end

      protected

      attr_reader :node

      private

      def scope_argument
        node.method_args.first
      end
    end
  end
end
