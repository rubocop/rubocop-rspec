# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that around blocks actually run the test.
      #
      # @example
      #   # bad
      #   around do
      #     some_method
      #   end
      #
      #   around do |test|
      #     some_method
      #   end
      #
      #   # good
      #   around do |test|
      #     some_method
      #     test.call
      #   end
      #
      #   around do |test|
      #     some_method
      #     test.run
      #   end
      #
      class AroundBlock < Base
        MSG_NO_ARG     = 'Test object should be passed to around block.'
        MSG_UNUSED_ARG = 'You should call `%<arg>s.call` ' \
                         'or `%<arg>s.run`.'

        # @!method hook_block(node)
        def_node_matcher :hook_block, <<~PATTERN
          (block (send nil? :around sym ?) (args $...) ...)
        PATTERN

        # @!method hook_numblock(node)
        def_node_matcher :hook_numblock, <<~PATTERN
          (numblock (send nil? :around sym ?) ...)
        PATTERN

        # @!method hook_itblock(node)
        def_node_matcher :hook_itblock, <<~PATTERN
          (itblock (send nil? :around sym ?) ...)
        PATTERN

        # @!method find_arg_usage(node)
        def_node_search :find_arg_usage, <<~PATTERN
          {(send $... {:call :run}) (send _ _ $...) (yield $...) (block-pass $...)}
        PATTERN

        def on_block(node)
          hook_block(node) do |(example_proxy)|
            if example_proxy.nil?
              add_no_arg_offense(node)
            else
              check_for_unused_proxy(node, example_proxy, example_proxy.name)
            end
          end
        end

        def on_numblock(node)
          hook_numblock(node) do
            check_for_unused_proxy(node, node.children.last, :_1)
          end
        end

        def on_itblock(node)
          hook_itblock(node) do
            check_for_unused_proxy(node, node.children.last, :it)
          end
        end

        private

        def add_no_arg_offense(node)
          add_offense(node, message: MSG_NO_ARG)
        end

        def check_for_unused_proxy(block, range, name)
          find_arg_usage(block) do |usage|
            return if usage.include?(s(:lvar, name))
          end

          add_offense(
            range,
            message: format(MSG_UNUSED_ARG, arg: name)
          )
        end
      end
    end
  end
end
