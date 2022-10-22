# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Use consistent style block delimiters for memoized helpers.
      #
      # @example EnforcedStyle: do_end (default)
      #   # bad
      #   let(:foo) { 'bar' }
      #
      #   # good
      #   let(:foo) do
      #     'bar'
      #   end
      #
      #   # bad
      #   subject(:foo) { 'bar' }
      #
      #   # good
      #   subject(:foo) do
      #     'bar'
      #   end
      #
      # @example EnforcedStyle: braces
      #   # bad
      #   let(:foo) do
      #     'bar'
      #   end
      #
      #   # good
      #   let(:foo) { 'bar' }
      #
      #   # bad
      #   subject(:foo) do
      #     'bar'
      #   end
      #
      #   # good
      #   subject(:foo) { 'bar' }
      class MemoizedHelperBlockDelimiter < Base
        extend AutoCorrector

        include ConfigurableEnforcedStyle
        include RangeHelp
        include RuboCop::RSpec::Language

        # @param node [RuboCop::AST::BlockNode]
        # @return [void]
        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless bad?(node)

          add_offense(
            node.location.begin.with(
              end_pos: node.location.end.end_pos
            ),
            message: "Use #{style} style block delimiters."
          ) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        # @param corrector [RuboCop::Cop::Corrector]
        # @param node [RuboCop::AST::BlockNode]
        # @return [void]
        def autocorrect(corrector, node)
          case style
          when :braces
            # Not supported because it conflicts with Style/BlockDelimiters.
          when :do_end
            autocorrect_braces(corrector, node)
          end
        end

        # @param corrector [RuboCop::Cop::Corrector]
        # @param node [RuboCop::AST::BlockNode]
        # @return [void]
        def autocorrect_braces(corrector, node)
          unless whitespace_before?(node.location.begin)
            corrector.insert_before(node.location.begin, ' ')
          end
          corrector.replace(node.location.begin, 'do')
          corrector.replace(node.location.end, 'end')
          wrap_in_newlines(corrector, node) if node.single_line?
        end

        # @param node [RuboCop::AST::BlockNode]
        # @return [Boolean]
        def bad?(node)
          memoized_helper_method?(node) &&
            !preferred_block_delimiter?(node)
        end

        # @param node [RuboCop::AST::BlockNode]
        # @return [Boolean]
        def memoized_helper_method?(node)
          let?(node) || subject?(node)
        end

        # @param node [RuboCop::AST::BlockNode]
        # @return [Boolean]
        def preferred_block_delimiter?(node)
          case style
          when :braces
            node.braces?
          when :do_end
            !node.braces?
          end
        end

        # @param range [Parser::Source::Range]
        # @return [Boolean]
        def whitespace_before?(range)
          range.source_buffer.source[range.begin_pos - 1].match?(/\s/)
        end

        # @param corrector [RuboCop::Cop::Corrector]
        # @param node [RuboCop::AST::BlockNode]
        # @return [void]
        def wrap_in_newlines(corrector, node)
          corrector.wrap(
            node.location.begin.with(
              begin_pos: node.location.begin.end_pos,
              end_pos: node.location.end.begin_pos
            ),
            "\n",
            "\n"
          )
        end
      end
    end
  end
end
