# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after the last let block.
      #
      # @example
      #   # bad
      #     let(:foo) { bar }
      #     let(:something) { other }
      #     it do
      #       ...
      #     end
      #
      #   # good
      #     let(:foo) { bar }
      #     let(:something) { other }
      #
      #     it do
      #       ...
      #     end
      class EmptyLineAfterFinalLet < Cop
        MSG = 'Add an empty line after the last `let` block.'.freeze

        def_node_matcher :let?, '(block $(send nil {:let :let!} ...) args ...)'

        def on_block(node)
          return unless let?(node) && !in_spec_block?(node)

          latest_let = node
          node.parent.each_child_node do |sibling|
            latest_let = sibling if let?(sibling)
          end

          return if latest_let.equal?(node.parent.children.last)

          no_new_line_after(latest_let) do
            add_offense(latest_let, :expression)
          end
        end

        def autocorrect(node)
          loc = last_node_loc(node)
          ->(corrector) { corrector.insert_after(loc.end, "\n") }
        end

        private

        def no_new_line_after(node)
          loc = last_node_loc(node)

          next_line = processed_source[loc.line]

          yield unless next_line.blank?
        end

        def last_node_loc(node)
          last_line = node.loc.end.line
          heredoc_line(node) do |loc|
            return loc if loc.line > last_line
          end
          node.loc.end
        end

        def heredoc_line(node, &block)
          yield node.loc.heredoc_end if node.loc.respond_to?(:heredoc_end)

          node.each_child_node { |child| heredoc_line(child, &block) }
        end

        def in_spec_block?(node)
          node.each_ancestor(:block).any? do |ancestor|
            Examples::ALL.include?(ancestor.method_name)
          end
        end
      end
    end
  end
end
