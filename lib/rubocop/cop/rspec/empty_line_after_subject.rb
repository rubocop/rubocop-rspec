# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after subject block.
      #
      # @example
      #   # bad
      #     subject(:obj) { described_class }
      #     let(:foo) { bar }
      #
      #   # good
      #     subject(:obj) { described_class }
      #
      #     let(:foo) { bar }
      class EmptyLineAfterSubject < Cop
        MSG = 'Add empty line after `subject`.'.freeze

        def_node_matcher :subject?, '(block $(send nil :subject ...) args ...)'

        def on_block(node)
          return unless subject?(node) && !in_spec_block?(node)
          return if node.equal?(node.parent.children.last)

          send_line = node.loc.end.line
          next_line = processed_source[send_line]
          return if next_line.blank?

          add_offense(node, :expression, MSG)
        end

        def autocorrect(node)
          ->(corrector) { corrector.insert_after(node.loc.end, "\n") }
        end

        private

        def in_spec_block?(node)
          node.each_ancestor(:block).any? do |ancestor|
            Examples::ALL.include?(ancestor.method_name)
          end
        end
      end
    end
  end
end
