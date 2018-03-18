# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Prefer declaring dynamic attribute values in a block.
        #
        # @see StaticAttributeDefinedDynamically
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
        class DynamicAttributeDefinedStatically < Cop
          MSG = 'Use a block to set a dynamic value to an attribute.'.freeze

          def_node_matcher :value_matcher, <<-PATTERN
            (send nil? _ $...)
          PATTERN

          def_node_search :factory_attributes, <<-PATTERN
            (block (send nil? {:factory :trait} ...) _ { (begin $...) $(send ...) } )
          PATTERN

          def_node_matcher :callback_with_symbol_proc?, <<-PATTERN
            (send nil? {:before :after} sym (block_pass sym))
          PATTERN

          def on_block(node)
            factory_attributes(node).to_a.flatten.each do |attribute|
              next if callback_with_symbol_proc?(attribute) ||
                  static?(attribute)
              add_offense(attribute, location: :expression)
            end
          end

          def autocorrect(node)
            if !method_uses_parens?(node.location)
              autocorrect_without_parens(node)
            elsif value_hash_without_braces?(node.descendants.first)
              autocorrect_hash_without_braces(node)
            else
              autocorrect_replacing_parens(node)
            end
          end

          private

          def static?(attribute)
            value_matcher(attribute).to_a.all?(&:recursive_literal_or_const?)
          end

          def value_hash_without_braces?(node)
            node.hash_type? && !node.braces?
          end

          def method_uses_parens?(location)
            return false unless location.begin && location.end
            location.begin.source == '(' && location.end.source == ')'
          end

          def autocorrect_hash_without_braces(node)
            autocorrect_replacing_parens(node, ' { { ', ' } }')
          end

          def autocorrect_replacing_parens(node,
                                           start_token = ' { ',
                                           end_token = ' }')
            lambda do |corrector|
              corrector.replace(node.location.begin, start_token)
              corrector.replace(node.location.end, end_token)
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
