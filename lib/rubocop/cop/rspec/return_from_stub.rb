# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent style of stub's return setting.
      #
      # Enforces either `and_return` or block-style return in the cases
      # where the returned value is constant. Ignores dynamic returned values
      # as the result would be different.
      #
      # This cop can be configured using the `EnforcedStyle` option.
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

        def autocorrect(node)
          lambda do |corrector|
            if style == :and_return
              autocorrect_block_to_method(node, corrector)
            else
              autocorrect_method_to_block(node, corrector)
            end
          end
        end

        private

        def dynamic?(node)
          if node.array_type?
            return node.each_child_node.any? { |child| dynamic?(child) }
          end

          !node.literal?
        end

        def autocorrect_block_to_method(node, corrector)
          receive_with_block(node) do |args|
            replacement = ".and_return(#{args.source})"
            corrector.replace(block_range_with_space(node), replacement)
          end
        end

        def autocorrect_method_to_block(node, corrector)
          receive, _and_return, value = *node
          replacement = "#{receive.source} { #{value.source} }"
          corrector.replace(node.loc.expression, replacement)
        end

        def block_range_with_space(node)
          block_range = range_between(begin_pos_for_replacement(node),
                                      node.loc.end.end_pos)
          range_with_surrounding_space(block_range, :left)
        end

        def begin_pos_for_replacement(node)
          block_send_or_super, _block_args, _block_body = *node
          expr = block_send_or_super.source_range

          if (paren_pos = (expr.source =~ /\(\s*\)$/))
            expr.begin_pos + paren_pos
          else
            node.loc.begin.begin_pos
          end
        end
      end
    end
  end
end
