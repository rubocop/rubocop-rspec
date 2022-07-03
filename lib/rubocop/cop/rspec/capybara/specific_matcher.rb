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
        #   expect(page).to have_no_css('a.cls', exact_text: 'foo')
        #   expect(page).to have_css('table.cls')
        #   expect(page).to have_css('select')
        #
        #   # good
        #   expect(page).to have_button
        #   expect(page).to have_no_button(class: 'cls')
        #   expect(page).to have_button
        #   expect(page).to have_no_link('foo', class: 'cls')
        #   expect(page).to have_table(class: 'cls')
        #   expect(page).to have_select
        #
        class SpecificMatcher < Base
          MSG = 'Prefer `%<good_matcher>s` over `%<bad_matcher>s`.'
          RESTRICT_ON_SEND = %i[have_selector have_no_selector have_css
                                have_no_css].freeze
          SPECIFIC_MATCHER = {
            'button' => 'button',
            'a' => 'link',
            'table' => 'table',
            'select' => 'select'
          }.freeze

          # @!method first_argument(node)
          def_node_matcher :first_argument, <<-PATTERN
            (send nil? _ (str $_) ... )
          PATTERN

          def on_send(node)
            return unless (arg = first_argument(node))
            return unless (matcher = specific_matcher(arg))
            return if acceptable_pattern?(arg)

            add_offense(node, message: message(node, matcher))
          end

          private

          def specific_matcher(arg)
            splitted_arg = arg[/^\w+/, 0]
            SPECIFIC_MATCHER[splitted_arg]
          end

          def acceptable_pattern?(arg)
            arg.match?(/\[.+=\w+\]/) || arg.match?(/[ >,+]/)
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
