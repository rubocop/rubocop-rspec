# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Capybara
        # Checks for there is a more specific matcher offered by Capybara.
        #
        # @example
        #
        #   # bad
        #   expect(page).to have_selector('button')
        #   expect(page).to have_no_selector('button.cls')
        #   expect(page).to have_css('button')
        #   expect(page).to have_no_css('a.cls', href: 'http://example.com')
        #   expect(page).to have_css('table.cls')
        #   expect(page).to have_css('select')
        #   expect(page).to have_css('input', exact_text: 'foo')
        #
        #   # good
        #   expect(page).to have_button
        #   expect(page).to have_no_button(class: 'cls')
        #   expect(page).to have_button
        #   expect(page).to have_no_link('foo', class: 'cls', href: 'http://example.com')
        #   expect(page).to have_table(class: 'cls')
        #   expect(page).to have_select
        #   expect(page).to have_field('foo')
        #
        class SpecificMatcher < Base
          include CapybaraHelp

          MSG = 'Prefer `%<good_matcher>s` over `%<bad_matcher>s`.'
          RESTRICT_ON_SEND = %i[have_selector have_no_selector have_css
                                have_no_css].freeze
          SPECIFIC_MATCHER = {
            'button' => 'button',
            'a' => 'link',
            'table' => 'table',
            'select' => 'select',
            'input' => 'field'
          }.freeze

          # @!method first_argument(node)
          def_node_matcher :first_argument, <<-PATTERN
            (send nil? _ (str $_) ... )
          PATTERN

          def on_send(node)
            first_argument(node) do |arg|
              next unless (matcher = specific_matcher(arg))
              next if CssSelector.multiple_selectors?(arg)
              next unless specific_option?(node, arg, matcher)
              next unless specific_pseudo_classes?(arg)

              add_offense(node, message: message(node, matcher))
            end
          end

          private

          def specific_matcher(arg)
            splitted_arg = arg[/^\w+/, 0]
            SPECIFIC_MATCHER[splitted_arg]
          end

          def message(node, matcher)
            format(MSG,
                   good_matcher: good_matcher(node, matcher),
                   bad_matcher: node.method_name)
          end

          def good_matcher(node, matcher)
            node.method_name
              .to_s
              .gsub(/selector|css/, matcher.to_s)
          end
        end
      end
    end
  end
end
