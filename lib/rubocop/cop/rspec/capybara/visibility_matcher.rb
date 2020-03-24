# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Capybara
        # Checks for boolean visibility in capybara finders.
        #
        # Capybara lets you find elements that match a certain visibility using
        # the `:visible` option. `:visible` accepts both boolean and symbols as
        # values, however using booleans can have unwanted effects. `visible:
        # false` does not find just invisible elements, but both visible and
        # invisible elements. For expressiveness and clarity, use one of the
        # symbol values, `:all`, `:hidden` or `:visible`.
        # (https://www.rubydoc.info/gems/capybara/Capybara%2FNode%2FFinders:all)
        #
        # @example
        #
        #   # bad
        #   expect(page).to have_selector('.foo', visible: false)
        #
        #   # bad
        #   expect(page).to have_selector('.foo', visible: true)
        #
        #   # good
        #   expect(page).to have_selector('.foo', visible: :all)
        #
        #   # good
        #   expect(page).to have_selector('.foo', visible: :hidden)
        #
        #   # good
        #   expect(page).to have_selector('.foo', visible: :visible)
        #
        class VisibilityMatcher < Cop
          MSG_FALSE = 'Use `:all` or `:hidden` instead of `false`.'
          MSG_TRUE = 'Use `:visible` instead of `true`.'

          def_node_matcher :visible_true?, <<~PATTERN
            (send nil? :have_selector ... (hash <$(pair (sym :visible) true) ...>))
          PATTERN

          def_node_matcher :visible_false?, <<~PATTERN
            (send nil? :have_selector ... (hash <$(pair (sym :visible) false) ...>))
          PATTERN

          def on_send(node)
            visible_false?(node) { |arg| add_offense(arg, message: MSG_FALSE) }
            visible_true?(node) { |arg| add_offense(arg, message: MSG_TRUE) }
          end
        end
      end
    end
  end
end
