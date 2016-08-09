# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Omit the default :each argument for RSpec hooks.
      #
      # @example when configuration is `EnforcedStyle: implicit`
      #   # bad
      #   before(:each) do
      #     ...
      #   end
      #
      #   # bad
      #   before(:example) do
      #     ...
      #   end
      #
      #   # good
      #   before do
      #     ...
      #   end
      #
      # @example when configuration is `EnforcedStyle: each`
      #   # bad
      #   before(:example) do
      #     ...
      #   end
      #
      #   # good
      #   before do
      #     ...
      #   end
      #
      #   # good
      #   before(:each) do
      #     ...
      #   end
      #
      # @example when configuration is `EnforcedStyle: example`
      #   # bad
      #   before(:each) do
      #     ...
      #   end
      #
      #   # bad
      #   before do
      #     ...
      #   end
      #
      #   # good
      #   before(:example) do
      #     ...
      #   end
      class HookArgument < RuboCop::Cop::Cop
        include RuboCop::RSpec::Language,
                ConfigurableEnforcedStyle

        IMPLICIT_MSG = 'Omit the default `%p` argument for RSpec hooks.'.freeze
        EXPLICIT_MSG = 'Use `%p` for RSpec hooks.'.freeze

        HOOKS = "{#{Hooks::ALL.to_node_pattern}}".freeze

        EXPLICIT_STYLES = %i(each example).freeze

        def_node_matcher :scoped_hook, <<-PATTERN
        (block (send nil #{HOOKS} $(sym ${:each :example})) ...)
        PATTERN

        def_node_matcher :unscoped_hook, "(block (send nil #{HOOKS}) ...)"

        def on_block(node)
          hook(node) do |scope, scope_name|
            return correct_style_detected if scope_name.equal?(style)
            return check_implicit(node) unless scope

            style_detected(scope_name)
            add_offense(scope, :expression, explicit_message(scope_name))
          end
        end

        private

        def check_implicit(node)
          style_detected(:implicit)
          return if implicit_style?

          method_send, = *node
          add_offense(method_send, :selector, format(EXPLICIT_MSG, style))
        end

        def explicit_message(scope)
          if implicit_style?
            format(IMPLICIT_MSG, scope)
          else
            format(EXPLICIT_MSG, style)
          end
        end

        def implicit_style?
          style.equal?(:implicit)
        end

        def hook(node, &block)
          scoped_hook(node, &block) || unscoped_hook(node, &block)
        end
      end
    end
  end
end
