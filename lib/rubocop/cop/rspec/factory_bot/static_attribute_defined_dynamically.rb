# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Prefer declaring static attribute values without a block.
        #
        # @see DynamicAttributeDefinedStatically
        #
        # @example
        #   # bad
        #   kind { :static }
        #
        #   # good
        #   kind :static
        #
        #   # bad
        #   comments_count { 0 }
        #
        #   # good
        #   comments_count 0
        #
        #   # bad
        #   type { User::MAGIC }
        #
        #   # good
        #   type User::MAGIC
        class StaticAttributeDefinedDynamically < Cop
          MSG = 'Do not use a block to set a static value ' \
                'to an attribute.'.freeze

          def_node_matcher :block_value_matcher, <<-PATTERN
            (block (send nil? _) _ $...)
          PATTERN

          def_node_search :factory_attributes, <<-PATTERN
            (block (send nil? { :factory :trait } ...) _ { (begin $...) $(send ...) $(block ...) } )
          PATTERN

          def on_block(node)
            factory_attributes(node).to_a.flatten.each do |attribute|
              values = block_value_matcher(attribute)
              next if values.to_a.none? { |v| static?(v) }
              add_offense(attribute, location: :expression)
            end
          end

          def autocorrect(node)
            lambda do |corrector|
              corrector.replace(
                node.loc.expression,
                autocorrected_source(node)
              )
            end
          end

          private

          def static?(node)
            node.recursive_literal? || node.const_type?
          end

          def autocorrected_source(node)
            if node.body.hash_type?
              "#{node.send_node.source}(#{node.body.source})"
            else
              "#{node.send_node.source} #{node.body.source}"
            end
          end
        end
      end
    end
  end
end
