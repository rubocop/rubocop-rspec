# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for expectations with `!`.
      #
      # @safety
      #   The autocorrection is marked as unsafe, because it may change the
      #   expectation from a positive to a negative one, or vice versa.
      #
      # @example
      #   # bad
      #   !expect(foo).to be_valid
      #
      #   # good
      #   expect(foo).not_to be_valid
      #
      class NegatedExpectation < Base
        extend AutoCorrector

        MSG = 'Use `expect(...).%<replaced>s` instead of ' \
              '`!expect(...)`.%<runner>s'
        RESTRICT_ON_SEND = Runners.all

        def on_send(node)
          return unless node.parent&.send_type?
          return unless node.parent.method?(:!)

          replaced = replaced(node)
          add_offense(node.parent,
                      message: message(node, replaced)) do |corrector|
            corrector.remove(node.parent.loc.selector)
            corrector.replace(node.loc.selector, replaced(node))
          end
        end

        private

        def message(node, replaced)
          format(MSG, runner: node.loc.selector, replaced: replaced)
        end

        def replaced(node)
          runner = node.loc.selector.source
          runner == 'to' ? 'not_to' : 'to'
        end
      end
    end
  end
end
