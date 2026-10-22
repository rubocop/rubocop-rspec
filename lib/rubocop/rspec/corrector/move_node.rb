# frozen_string_literal: true

module RuboCop
  module RSpec
    module Corrector
      # Helper methods to move a node
      #
      # A Sorbet `sig` block directly above the moved node is moved with it,
      # and inserting before a node keeps that node's own `sig` attached.
      class MoveNode
        extend RuboCop::AST::NodePattern::Macros
        include RuboCop::Cop::RangeHelp
        include RuboCop::Cop::RSpec::CommentsHelp
        include RuboCop::Cop::RSpec::FinalEndLocation

        attr_reader :original, :corrector, :processed_source

        def initialize(node, corrector, processed_source)
          @original = node
          @corrector = corrector
          @processed_source = processed_source # used by RangeHelp
        end

        # @!method sig_block?(node)
        def_node_matcher :sig_block?, '(block (send nil? :sig ...) _ _)'

        def move_before(other)
          position = start_line_position(preceding_sig(other) || other)

          corrector.insert_before(position, "#{source(original)}\n")
          corrector.remove(node_range_with_surrounding_space(original))
        end

        def move_after(other)
          position = end_line_position(other)

          corrector.insert_after(position, "\n#{source(original)}")
          corrector.remove(node_range_with_surrounding_space(original))
        end

        private

        def source(node)
          node_range(node).source
        end

        def node_range(node)
          sig = preceding_sig(node)
          return source_range_with_comment(node) unless sig

          Parser::Source::Range.new(
            buffer,
            begin_pos_with_comment(sig).begin_pos,
            end_line_position(node).end_pos
          )
        end

        def preceding_sig(node)
          previous = node.left_sibling
          previous if previous.is_a?(RuboCop::AST::Node) && sig_block?(previous)
        end

        def node_range_with_surrounding_space(node)
          range = node_range(node)
          range_by_whole_lines(range, include_final_newline: true)
        end
      end
    end
  end
end
