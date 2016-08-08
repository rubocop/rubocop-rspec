# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Omit the default :each argument for RSpec hooks.
      #
      # @example
      #   # bad
      #   before(:each) do
      #     ...
      #   end
      #
      #   # good
      #   before do
      #     ...
      #   end
      class HookArgument < RuboCop::Cop::Cop
        MSG = 'Omit the default `:%s` argument for RSpec hooks.'.freeze

        HOOK_METHODS = [:after, :around, :before].freeze
        DEFAULT_ARGS = [:each, :example].freeze

        def on_send(node)
          return unless HOOK_METHODS.include?(node.method_name)

          arg_node = node.method_args.first
          arg, = *arg_node

          return unless DEFAULT_ARGS.include?(arg)

          add_offense(arg_node, :expression, format(MSG, arg))
        end
      end
    end
  end
end
