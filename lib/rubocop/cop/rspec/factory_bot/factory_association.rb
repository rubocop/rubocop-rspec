# frozen_string_literal: true

require 'rubocop'

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # This cop looks for 'association' in factories that specify a
        # ':factory' option and tells you to use explicit build reference
        # which improves the performance as cascading factories
        # will not be saved unless needed to
        #
        # @example
        #   #bad
        #    FactoryBot.define do
        #      factory :book do
        #        title { 'Lord of the Rings' }
        #        association :author
        #      end
        #    end
        #
        #    FactoryBoy.define do
        #      factory :book do
        #        title {'Lord of the Rings'}
        #        author { association :author }
        #      end
        #    end
        #
        #    #good
        #    FactoryBot.define do
        #      factory :book do
        #        title { 'Lord of the Rings' }
        #        author { build(:author) }
        #      end
        #    end
        #
        #    FactoryBot.define do
        #      factory :author do
        #        name { 'J. R. R. Tolkien' }
        #      end
        #    end
        class FactoryAssociation < ::RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use %<association>s { build(:%<factory>s) } instead'

          # @!method association_definition(node)
          def_node_matcher :association_definition, <<~PATTERN
            (send nil? :association (:sym $_) (hash (pair (sym :factory) (:sym $_))) ?)
          PATTERN

          # @!method inline_association_definition(node)
          def_node_matcher :inline_association_definition, <<~PATTERN
            (block (send nil? $_) (args) (send nil? :association (sym $_)))
          PATTERN

          def on_block(node)
            inline_association_definition(node) do |association, factory|
              message = format(MSG, association: association.to_s,
                                    factory: factory.to_s)

              add_offense(node, message: message) do |corrector|
                corrector.replace(node, replacement(association, factory))
              end
            end
          end

          def on_send(node)
            return unless @current_corrector.empty?

            association_definition(node) do |association, factory|
              factory = [association] if factory.empty?

              message = format(MSG, association: association.to_s,
                                    factory: factory.first.to_s)

              add_offense(node, message: message) do |corrector|
                corrector.replace(node, replacement(association, factory.first))
              end
            end
          end

          private

          def expression(node)
            if node.block_type?
              inline_association_definition(node)
            else
              association_definition(node).flatten
            end
          end

          def replacement(association, factory)
            "#{association} { build(:#{factory}) }"
          end
        end
      end
    end
  end
end
