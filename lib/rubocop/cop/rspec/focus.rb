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
        MESSAGE = 'Focused spec found.'.freeze

        FOCUSABLE_BLOCKS = [
          :example_group, :describe, :context, :xdescribe, :xcontext,
          :it, :example, :specify, :xit, :xexample, :xspecify,
          :feature, :scenario, :xfeature, :xscenario
        ].freeze

        FOCUSED_BLOCKS = [
          :fdescribe, :fcontext,
          :focus, :fexample, :fit, :fspecify,
          :ffeature, :fscenario
        ].freeze

        FOCUS_KEY = s(:sym, :focus)

        FOCUS_TRUE_PAIR = s(:pair, FOCUS_KEY, s(:true))

        def on_send(node)
          _receiver, method_name, *_args = *node
          @focusable_block = FOCUSABLE_BLOCKS.include?(method_name)
          if FOCUSED_BLOCKS.include?(method_name)
            add_offense(node, :expression, MESSAGE)
          end

          # check for :focus
          return unless @focusable_block
          node.children.any? do |n|
            add_offense(n, :expression, MESSAGE) if n == FOCUS_KEY
          end
        end

        def on_hash(node)
          return unless @focusable_block
          return if node.children.any? do |n|
            if [FOCUS_TRUE_PAIR].include?(n)
              add_offense(n, :expression, MESSAGE)
            end
          end
        end
      end
    end
  end
end
