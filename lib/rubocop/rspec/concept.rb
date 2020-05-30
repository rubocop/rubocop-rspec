# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec DSL methods
    class Concept
      include Language
      include Language::NodePattern
      include ConfigShortcuts
      extend NodePattern::Macros

      def initialize(node, config = nil)
        @node = node
        @config = config
      end

      def eql?(other)
        node == other.node
      end

      alias == eql?

      def hash
        [self.class, node].hash
      end

      def to_node
        node
      end

      protected

      attr_reader :node
      attr_reader :config
    end
  end
end
