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
        MSG = 'Omit the default `%p` argument for RSpec hooks.'.freeze

        HOOKS = '{:before :after :around}'.freeze

        def_node_matcher :scoped_hook, <<-PATTERN
        (block (send nil #{HOOKS} $(sym {:each :example})) ...)
        PATTERN

        def_node_matcher :unscoped_hook, "(block (send nil #{HOOKS}) ...)"

        def on_block(node)
          hook(node) do |scope|
            return unless scope

            add_offense(scope, :expression, format(MSG, *scope))
          end
        end

        private

        def hook(node, &block)
          scoped_hook(node, &block) || unscoped_hook(node, &block)
        end
      end
    end
  end
end
