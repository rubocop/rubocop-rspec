# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryGirl
        # Prefer declaring dynamic attribute values in a block.
        #
        # @example
        #   # bad
        #   kind [:active, :rejected].sample
        #
        #   # good
        #   kind { [:active, :rejected].sample }
        #
        #   # bad
        #   closed_at 1.day.from_now
        #
        #   # good
        #   closed_at { 1.day.from_now }
        #
        #   # good
        #   kind :static
        #
        #   # good
        #   comments_count 0
        #
        #   # good
        #   type User::MAGIC
        class DynamicAttributeDefinedStatically < Cop
          MSG = 'Use a block to set a dynamic value to an attribute.'.freeze

          def_node_matcher :dynamic_defined_statically?, <<-PATTERN
          (send nil _ (send ... ))
          PATTERN

          def_node_search :factory_attributes, <<-PATTERN
          (block (send nil {:factory :trait} ...) _ { (begin $...) $(send ...) } )
          PATTERN

          def on_block(node)
            return if node.method_name == :trait
            factory_attributes(node).to_a.flatten.each do |attribute|
              if dynamic_defined_statically?(attribute)
                add_offense(attribute, :expression)
              end
            end
          end

          def autocorrect(node)
            if method_uses_parens?(node.location)
              autocorrect_replacing_parens(node)
            else
              autocorrect_without_parens(node)
            end
          end

          private

          def method_uses_parens?(location)
            return false unless location.begin && location.end
            location.begin.source == '(' && location.end.source == ')'
          end

          def autocorrect_replacing_parens(node)
            lambda do |corrector|
              corrector.replace(node.location.begin, ' { ')
              corrector.replace(node.location.end, ' }')
            end
          end

          def autocorrect_without_parens(node)
            lambda do |corrector|
              arguments = node.descendants.first
              expression = arguments.location.expression
              corrector.insert_before(expression, '{ ')
              corrector.insert_after(expression, ' }')
            end
          end
        end
      end
    end
  end
end
