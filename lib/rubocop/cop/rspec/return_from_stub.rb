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

        def_node_matcher :and_return_value, <<-PATTERN
            (send
              (send nil :receive (...)) :and_return $(...)
            )
        PATTERN

        def on_send(node)
          if style == :block
            check_and_return_call(node)
          elsif node.method_name == :receive
            check_block_body(node)
          end
        end

        private

        def check_and_return_call(node)
          and_return_value(node) do |args|
            add_offense(node, :expression, MSG_BLOCK) unless dynamic?(args)
          end
        end

        def check_block_body(node)
          block = node.each_ancestor(:block).first
          return unless block

          _receiver, _args, body = *block
          add_offense(node, :expression, MSG_AND_RETURN) unless dynamic?(body)
        end

        def dynamic?(node)
          !node.recursive_literal?
        end
      end
    end
  end
end
