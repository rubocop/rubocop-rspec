# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if test is focused.
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

        FOCUSABLE_SELECTORS = '
          :context
          :describe
          :example
          :example_group
          :feature
          :it
          :scenario
          :specify
          :xcontext
          :xdescribe
          :xexample
          :xfeature
          :xit
          :xscenario
          :xspecify
        '.freeze

        FOCUSING_SELECTORS = '
          :fcontext
          :fdescribe
          :fexample
          :ffeature
          :fit
          :focus
          :fscenario
          :fspecify
        '.freeze

        FOCUS_SYMBOL = s(:sym, :focus)
        FOCUS_TRUE   = s(:pair, FOCUS_SYMBOL, s(:true))

        def_node_matcher :metadata, <<-PATTERN
          {(send nil {#{FOCUSABLE_SELECTORS}} ... (hash $...))
           (send nil {#{FOCUSABLE_SELECTORS}} $...)}
        PATTERN

        def_node_matcher :focused_block?, <<-PATTERN
          (send nil {#{FOCUSING_SELECTORS}} ...)
        PATTERN

        def on_send(node)
          focus_metadata(node) do |focus|
            add_offense(focus, :expression)
          end
        end

        private

        def focus_metadata(node, &block)
          yield(node) if focused_block?(node)

          metadata(node) do |matches|
            matches.grep(FOCUS_SYMBOL, &block)
            matches.grep(FOCUS_TRUE, &block)
          end
        end
      end
    end
  end
end
