# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after hook blocks.
      #
      # @example
      #   # bad
      #   before { do_something }
      #   it { does_something }
      #
      #   # bad
      #   after { do_something }
      #   it { does_something }
      #
      #   # bad
      #   around { |test| test.run }
      #   it { does_something }
      #
      #   # good
      #   before { do_something }
      #
      #   it { does_something }
      #
      #   # good
      #   after { do_something }
      #
      #   it { does_something }
      #
      #   # good
      #   around { |test| test.run }
      #
      #   it { does_something }
      #
      class EmptyLineAfterHook < Cop
        MSG = 'Add an empty line after `%<hook>s`.'.freeze

        def_node_matcher :hook?, Hooks::ALL.block_pattern

        def on_block(node)
          return unless hook?(node)
          return if node.equal?(node.parent.children.last)

          return if next_line(node).blank?

          add_offense(
            node,
            location: :expression,
            message: format(MSG, hook: node.method_name)
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
