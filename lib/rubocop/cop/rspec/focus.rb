# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if examples are focused.
      #
      # @example
      #   # bad
      #   describe MyClass, focus: true do
      #   end
      #
      #   describe MyClass, :focus do
      #   end
      #
      #   fdescribe MyClass do
      #   end
      #
      #   # good
      #   describe MyClass do
      #   end
      class Focus < Cop
        MSG = 'Focused spec found.'.freeze

        focusable =
          ExampleGroups::GROUPS  +
          ExampleGroups::SKIPPED +
          Examples::EXAMPLES     +
          Examples::SKIPPED

        focused = ExampleGroups::FOCUSED + Examples::FOCUSED

        FOCUSABLE_SELECTORS = focusable.node_pattern_union

        FOCUS_SYMBOL = s(:sym, :focus)
        FOCUS_TRUE   = s(:pair, FOCUS_SYMBOL, s(:true))

        def_node_matcher :metadata, <<-PATTERN
          {(send nil? #{FOCUSABLE_SELECTORS} ... (hash $...))
           (send nil? #{FOCUSABLE_SELECTORS} $...)}
        PATTERN

        def_node_matcher :focused_block?, focused.block_pattern

        def on_block(node)
          focus_metadata(node) do |focus|
            add_offense(focus, :expression)
          end
        end

        private

        def focus_metadata(node, &block)
          example_node, = *node
          yield(example_node) if focused_block?(node)

          metadata(example_node) do |matches|
            matches.grep(FOCUS_SYMBOL, &block)
            matches.grep(FOCUS_TRUE, &block)
          end
        end
      end
    end
  end
end
