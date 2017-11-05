# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Prefer declaring associations using the `#association` method.
        #
        # @example
        #   # bad
        #   factory :post do
        #     comments
        #   end
        #
        #   # good
        #   factory :post do
        #     association :comments
        #   end
        class DynamicAssociationDeclaration < Cop
          MSG = 'Use `association :%<name>s` to declare association.'.freeze

          FACTORY_BOT_METHODS = %i[skip_create].freeze

          def_node_matcher :dynamic_association_declaration, <<-PATTERN
            (send nil? [!#whitelisted_method? $_])
          PATTERN

          def_node_search :factory_attributes, <<-PATTERN
            (block (send nil? {:factory :trait} ...) _ {(begin $...) $(send ...)})
          PATTERN

          def on_block(node)
            factory_attributes(node).to_a.flatten.each do |attribute|
              dynamic_association_declaration(attribute) do |name|
                add_offense(attribute, message: format(MSG, name: name))
              end
            end
          end

          def autocorrect(node)
            correction = "association :#{node.method_name}"

            ->(corrector) { corrector.replace(node.loc.expression, correction) }
          end

          private

          def whitelisted_method?(method_name)
            FACTORY_BOT_METHODS.include?(method_name)
          end
        end
      end
    end
  end
end
