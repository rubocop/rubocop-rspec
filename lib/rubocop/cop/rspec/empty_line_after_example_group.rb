# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after example group blocks.
      #
      # @example
      #   # bad
      #   RSpec.describe Foo do
      #     describe '#bar' do
      #     end
      #     describe '#baz' do
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe Foo do
      #     describe '#bar' do
      #     end
      #
      #     describe '#baz' do
      #     end
      #   end
      #
      class EmptyLineAfterExampleGroup < Cop
        MSG = 'Add an empty line after `%<example_group>s`.'.freeze

        def_node_matcher :example_group, ExampleGroups::ALL.block_pattern

        def on_block(node)
          return unless example_group(node)
          return if node.parent && node.equal?(node.parent.children.last)

          return if next_line(node).blank?

          add_offense(
            node,
            location: node.loc.end,
            message: format(MSG, example_group: node.method_name)
          )
        end

        def autocorrect(node)
          ->(corrector) { corrector.insert_after(node.loc.end, "\n") }
        end

        private

        def next_line(node)
          send_line = node.loc.end.line
          processed_source[send_line]
        end
      end
    end
  end
end
