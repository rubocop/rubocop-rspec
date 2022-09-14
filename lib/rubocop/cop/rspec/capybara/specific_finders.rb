# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Capybara
        # Checks if there is a more specific finder offered by Capybara.
        #
        # @example
        #   # bad
        #   find('#some-id')
        #   find('[visible][id=some-id]')
        #
        #   # good
        #   find_by_id('some-id')
        #   find_by_id('some-id', visible: true)
        #
        class SpecificFinders < Base
          extend AutoCorrector

          include RangeHelp

          MSG = 'Prefer `find_by` over `find`.'
          RESTRICT_ON_SEND = %i[find].freeze

          # @!method find_argument(node)
          def_node_matcher :find_argument, <<~PATTERN
            (send _ :find (str $_) ...)
          PATTERN

          def on_send(node)
            find_argument(node) do |arg|
              next if CssSelector.multiple_selectors?(arg)

              on_attr(node, arg) if attribute?(arg)
              on_id(node, arg) if CssSelector.id?(arg)
            end
          end

          private

          def on_attr(node, arg)
            return unless (id = CssSelector.attributes(arg)['id'])

            register_offense(node, replaced_arguments(arg, id))
          end

          def on_id(node, arg)
            register_offense(node, "'#{arg.to_s.delete('#')}'")
          end

          def attribute?(arg)
            CssSelector.attribute?(arg) &&
              CssSelector.common_attributes?(arg)
          end

          def register_offense(node, arg_replacement)
            add_offense(offense_range(node)) do |corrector|
              corrector.replace(node.loc.selector, 'find_by_id')
              corrector.replace(node.first_argument.loc.expression,
                                arg_replacement)
            end
          end

          def replaced_arguments(arg, id)
            options = to_options(CssSelector.attributes(arg))
            options.empty? ? id : "#{id}, #{options}"
          end

          def to_options(attrs)
            attrs.each.map do |key, value|
              next if key == 'id'

              "#{key}: #{value}"
            end.compact.join(', ')
          end

          def offense_range(node)
            range_between(node.loc.selector.begin_pos, end_pos(node))
          end

          def end_pos(node)
            if node.loc.end
              node.loc.end.end_pos
            else
              node.loc.expression.end_pos
            end
          end
        end
      end
    end
  end
end
