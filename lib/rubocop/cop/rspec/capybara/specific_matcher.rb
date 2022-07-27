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
          COMMON_OPTIONS = %w[
            above below left_of right_of near count minimum maximum between text
            id class style visible obscured exact exact_text normalize_ws match
            wait filter_set focused
          ].freeze
          HAVE_BUTTON_OPTIONS = COMMON_OPTIONS + %w[
            disabled name value title type
          ].freeze
          HAVE_LINK_OPTIONS = COMMON_OPTIONS + %w[
            href alt title download
          ].freeze
          HAVE_TABLE_OPTIONS = COMMON_OPTIONS + %w[
            caption with_cols cols with_rows rows
          ].freeze
          HAVE_SELECT_OPTIONS = COMMON_OPTIONS + %w[
            disabled name placeholder options enabled_options disabled_options
            selected with_selected multiple with_options
          ].freeze
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
            return unless specific_matcher_option?(arg, matcher)

            add_offense(node, message: message(node, matcher))
          end

          private

          def specific_matcher(arg)
            splitted_arg = arg[/^\w+/, 0]
            SPECIFIC_MATCHER[splitted_arg]
          end

          def acceptable_pattern?(arg)
            arg.match?(/[ >,+]/)
          end

          def specific_matcher_option?(arg, matcher)
            # If `button[foo-bar_baz=foo][bar][baz]`:
            # extract ["foo-bar_baz", "bar", "baz"]
            attributes = arg.scan(/\[(.*?)(?:=.*?)?\]/).flatten
            return true if attributes.empty?

            attributes.all? do |attr|
              specific_matcher_options(matcher).include?(attr)
            end
          end

          def specific_matcher_options(matcher)
            case matcher
            when 'button' then HAVE_BUTTON_OPTIONS
            when 'link' then HAVE_LINK_OPTIONS
            when 'table' then HAVE_TABLE_OPTIONS
            when 'select' then HAVE_SELECT_OPTIONS
            else []
            end
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
