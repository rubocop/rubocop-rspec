# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that before/around/after hooks are defined in the correct order.
      #
      # If multiple hooks are defined in example group, they should appear in
      # the following order:
      # before :suite
      # before :context
      # before :example
      # around :example
      # after :example
      # after :context
      # after :suite
      #
      # @example
      #  # bad
      #  after { run_cleanup }
      #  before { run_setup }
      #
      #  # good
      #  before { run_setup }
      #  after { run_cleanup }
      #
      class OrderedHooks < Base
        extend AutoCorrector

        MSG = '`%<hook>s` is supposed to appear before `%<previous>s`' \
          ' at line %<line>d.'

        EXPECTED_HOOK_ORDER = %i[before around after].freeze
        EXPECTED_SCOPE_ORDER = %i[suite context each].freeze

        def on_block(node)
          return unless example_group_with_body?(node)

          RuboCop::RSpec::ExampleGroup.new(node)
            .hooks
            .each_cons(2) { |previous, current| check_order(previous, current) }
        end

        private

        def check_order(previous, current)
          previous_idx = EXPECTED_HOOK_ORDER.index(previous.name)
          current_idx = EXPECTED_HOOK_ORDER.index(current.name)

          if previous_idx == current_idx
            check_scope_order(previous, current)
          elsif previous_idx > current_idx
            order_violation(previous, current)
          end
        end

        def check_scope_order(previous, current)
          previous_idx = EXPECTED_SCOPE_ORDER.index(previous.scope)
          current_idx = EXPECTED_SCOPE_ORDER.index(current.scope)

          if current.name == :after # for after we expect reversed order
            order_violation(previous, current) if previous_idx < current_idx
          elsif previous_idx > current_idx
            order_violation(previous, current)
          end
        end

        def order_violation(previous, current)
          message = format(MSG,
                           hook: format_hook(current),
                           previous: format_hook(previous),
                           line: previous.to_node.loc.line)

          add_offense(current.to_node.send_node, message: message)
        end

        def format_hook(hook)
          msg = hook.name.to_s
          raw_scope_name = hook.send(:scope_name)
          msg += "(:#{raw_scope_name})" if raw_scope_name
          msg
        end
      end
    end
  end
end
