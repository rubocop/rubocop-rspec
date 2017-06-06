# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent style of stub's return setting.
      #
      # Enforces either `and_return` or block-style return in the cases
      # where the returned value is constant. Ignores dynamic returned values
      # are the result would be different
      #
      # This cop can be configured using the `EnforcedStyle` option
      #
      # @example `EncorcedStyle: block`
      #   # bad
      #   allow(Foo).to receive(:bar).and_return("baz")
      #   expect(Foo).to receive(:bar).and_return("baz")
      #
      #   # good
      #   allow(Foo).to receive(:bar) { "baz" }
      #   expect(Foo).to receive(:bar) { "baz" }
      #   # also good as the returned value is dynamic
      #   allow(Foo).to receive(:bar).and_return(bar.baz)
      #
      # @example `EncorcedStyle: and_return`
      #   # bad
      #   allow(Foo).to receive(:bar) { "baz" }
      #   expect(Foo).to receive(:bar) { "baz" }
      #
      #   # good
      #   allow(Foo).to receive(:bar).and_return("baz")
      #   expect(Foo).to receive(:bar).and_return("baz")
      #   # also good as the returned value is dynamic
      #   allow(Foo).to receive(:bar) { bar.baz }
      #
      class ReturnFromStub < Cop
        include ConfigurableEnforcedStyle

        MSG_AND_RETURN = 'Use `and_return` for static values.'.freeze
        MSG_BLOCK = 'Use block for static values.'.freeze

        def_node_matcher :receive_with_block, <<-PATTERN
          (block
            (send nil :receive ...)
            (args)
            $(...)
          )
        PATTERN

        def_node_matcher :and_return_value, <<-PATTERN
            (send
              (send nil :receive (...)) :and_return $(...)
            )
        PATTERN

        def on_block(node)
          return unless style == :and_return
          receive_with_block(node) do |args|
            add_offense(node, :expression, MSG_AND_RETURN) unless dynamic?(args)
          end
        end

        def on_send(node)
          return unless style == :block

          and_return_value(node) do |args|
            add_offense(node, :expression, MSG_BLOCK) unless dynamic?(args)
          end
        end

        private

        def dynamic?(node)
          if node.array_type?
            return node.each_child_node.any? { |child| dynamic?(child) }
          end

          !node.literal?
        end
      end
    end
  end
end
