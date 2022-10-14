# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Capybara
        # Checks for there is a more specific actions offered by Capybara.
        #
        # @example
        #
        #   # bad
        #   find('a').click
        #   find('button.cls').click
        #   find('a', exact_text: 'foo').click
        #   find('div button').click
        #
        #   # good
        #   click_link
        #   click_button(class: 'cls')
        #   click_link(exact_text: 'foo')
        #   find('div').click_button
        #
        class SpecificActions < Base
          MSG = "Prefer `%<good_action>s` over `find('%<selector>s').click`."
          RESTRICT_ON_SEND = %i[click].freeze
          SPECIFIC_ACTION = {
            'button' => 'button',
            'a' => 'link'
          }.freeze

          # @!method click_on_selector(node)
          def_node_matcher :click_on_selector, <<-PATTERN
            (send _ :find (str $_) ...)
          PATTERN

          # @!method option?(node)
          def_node_search :option?, <<-PATTERN
            (pair (sym %) _)
          PATTERN

          def on_send(node)
            click_on_selector(node.receiver) do |arg|
              next unless supported_selector?(arg)
              next unless (selector = last_selector(arg))
              next unless (action = specific_action(selector))
              next unless specific_action_option?(node.receiver, arg, action)
              next unless specific_action_pseudo_classes?(arg)

              range = offense_range(node, node.receiver)
              add_offense(range, message: message(action, selector))
            end
          end

          private

          def specific_action(selector)
            SPECIFIC_ACTION[last_selector(selector)]
          end

          def specific_action_option?(node, arg, action)
            attrs = CssSelector.attributes(arg).keys
            return false unless replaceable_action?(node, action, attrs)

            attrs.all? do |attr|
              CssSelector.specific_options?(action, attr)
            end
          end

          def specific_action_pseudo_classes?(arg)
            CssSelector.pseudo_classes(arg).all? do |pseudo_class|
              replaceable_pseudo_class?(pseudo_class, arg)
            end
          end

          def replaceable_pseudo_class?(pseudo_class, arg)
            unless CssSelector.specific_pesudo_classes?(pseudo_class)
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

          def replaceable_action?(node, action, attrs)
            case action
            when 'link' then replaceable_to_click_link?(node, attrs)
            else true
            end
          end

          def replaceable_to_click_link?(node, attrs)
            option?(node, :href) || attrs.include?('href')
          end

          def supported_selector?(selector)
            !selector.match?(/[>,+~]/)
          end

          def last_selector(arg)
            arg.split.last[/^\w+/, 0]
          end

          def offense_range(node, receiver)
            receiver.loc.selector.with(end_pos: node.loc.expression.end_pos)
          end

          def message(action, selector)
            format(MSG,
                   good_action: good_action(action),
                   selector: selector)
          end

          def good_action(action)
            "click_#{action}"
          end
        end
      end
    end
  end
end
