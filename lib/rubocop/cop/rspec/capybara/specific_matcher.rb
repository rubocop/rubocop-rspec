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
        class SpecificMatcher < Base # rubocop:disable Metrics/ClassLength
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
          SPECIFIC_MATCHER_OPTIONS = {
            'button' => (
              CssSelector::COMMON_OPTIONS + %w[disabled name value title type]
            ).freeze,
            'link' => (
              CssSelector::COMMON_OPTIONS + %w[href alt title download]
            ).freeze,
            'table' => (
              CssSelector::COMMON_OPTIONS + %w[
                caption with_cols cols with_rows rows
              ]
            ).freeze,
            'select' => (
              CssSelector::COMMON_OPTIONS + %w[
                disabled name placeholder options enabled_options
                disabled_options selected with_selected multiple with_options
              ]
            ).freeze,
            'field' => (
              CssSelector::COMMON_OPTIONS + %w[
                checked unchecked disabled valid name placeholder
                validation_message readonly with type multiple
              ]
            ).freeze
          }.freeze
          SPECIFIC_MATCHER_PSEUDO_CLASSES = %w[
            not() disabled enabled checked unchecked
          ].freeze

          # @!method first_argument(node)
          def_node_matcher :first_argument, <<-PATTERN
            (send nil? _ (str $_) ... )
          PATTERN

          # @!method option?(node)
          def_node_search :option?, <<-PATTERN
            (pair (sym %) _)
          PATTERN

          def on_send(node)
            first_argument(node) do |arg|
              next unless (matcher = specific_matcher(arg))
              next if CssSelector.multiple_selectors?(arg)
              next unless specific_matcher_option?(node, arg, matcher)
              next unless specific_matcher_pseudo_classes?(arg)

              add_offense(node, message: message(node, matcher))
            end
          end

          private

          def specific_matcher(arg)
            splitted_arg = arg[/^\w+/, 0]
            SPECIFIC_MATCHER[splitted_arg]
          end

          def specific_matcher_option?(node, arg, matcher)
            attrs = CssSelector.attributes(arg).keys
            return true if attrs.empty?
            return false unless replaceable_matcher?(node, matcher, attrs)

            attrs.all? do |attr|
              SPECIFIC_MATCHER_OPTIONS.fetch(matcher, []).include?(attr)
            end
          end

          def specific_matcher_pseudo_classes?(arg)
            CssSelector.pseudo_classes(arg).all? do |pseudo_class|
              replaceable_pseudo_class?(pseudo_class, arg)
            end
          end

          def replaceable_pseudo_class?(pseudo_class, arg)
            unless SPECIFIC_MATCHER_PSEUDO_CLASSES.include?(pseudo_class)
              return false
            end

            case pseudo_class
            when 'not()' then replaceable_pseudo_class_not?(arg)
            else true
            end
          end

          def replaceable_pseudo_class_not?(arg)
            arg.scan(/not\(.*?\)/).all? do |not_arg|
              CssSelector.attributes(not_arg).values.all? do |v|
                v.is_a?(TrueClass) || v.is_a?(FalseClass)
              end
            end
          end

          def replaceable_matcher?(node, matcher, attrs)
            case matcher
            when 'link' then replaceable_to_have_link?(node, attrs)
            else true
            end
          end

          def replaceable_to_have_link?(node, attrs)
            option?(node, :href) || attrs.include?('href')
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
