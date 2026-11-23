# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec examples
    class Example < Concept
      # @!method extract_doc_string(node)
      def_node_matcher :extract_doc_string, '(send _ _ $!block_pass ...)'

      # @!method extract_metadata(node)
      def_node_matcher :extract_metadata, <<~PATTERN
        {
          (send _ _ !block_pass $... block_pass)
          (send _ _ !block_pass $...)
        }
      PATTERN

      # @!method extract_implementation(node)
      def_node_matcher :extract_implementation, <<~PATTERN
        {
          (block send args $_)
          (send _ _ ... $block_pass)
        }
      PATTERN

      def doc_string
        extract_doc_string(definition)
      end

      def metadata
        extract_metadata(definition)
      end

      def implementation
        extract_implementation(node)
      end

      def definition
        if node.send_type?
          node
        else
          node.send_node
        end
      end
    end
  end
end
