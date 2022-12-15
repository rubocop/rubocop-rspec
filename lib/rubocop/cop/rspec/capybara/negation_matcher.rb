# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Capybara
        # Enforces use of `have_no_*` or `not_to` for negated expectations.
        #
        # @example EnforcedStyle: not_to (default)
        #   # bad
        #   expect(page).to have_no_selector
        #   expect(page).to have_no_css('a')
        #
        #   # good
        #   expect(page).not_to have_selector
        #   expect(page).not_to have_css('a')
        #
        # @example EnforcedStyle: have_no
        #   # bad
        #   expect(page).not_to have_selector
        #   expect(page).not_to have_css('a')
        #
        #   # good
        #   expect(page).to have_no_selector
        #   expect(page).to have_no_css('a')
        #
        # @!parse class NegationMatcher < ::RuboCop::Cop::Base; end
        class NegationMatcher < ::RuboCop::Cop::Capybara::NegationMatcher
        end
      end
    end
  end
end
