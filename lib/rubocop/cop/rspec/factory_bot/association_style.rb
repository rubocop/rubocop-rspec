# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Use consistent style to define associations.
        #
        # @safety
        #   This cop may cause false-positives in `EnforcedStyle: explicit`
        #   case. It recognizes any method call that has no arguments as an
        #   implicit association but it might be a user-defined trait call.
        #
        # @example EnforcedStyle: implicit (default)
        #   # bad
        #   association :user
        #
        #   # good
        #   user
        #
        # @example EnforcedStyle: explicit
        #   # bad
        #   user
        #
        #   # good
        #   association :user
        #
        #   # good (NonImplicitAssociationMethodNames: ['email'])
        #   email
        class AssociationStyle < Base # rubocop:disable Metrics/ClassLength
          extend AutoCorrector

          include ConfigurableEnforcedStyle

          DEFAULT_NON_IMPLICIT_ASSOCIATION_METHOD_NAMES = %w[
            association
            sequence
            skip_create
            traits_for_enum
          ].freeze

          RESTRICT_ON_SEND = %i[factory trait].freeze

          # @param node [RuboCop::AST::SendNode]
          # @return [void]
          def on_send(node)
            bad_associations_in(node).each do |association|
              add_offense(
                association,
                message: "Use #{style} style to define associations."
              ) do |corrector|
                autocorrect(corrector, association)
              end
            end
          end

          private

          # @!method explicit_association?(node)
          #   @param node [RuboCop::AST::SendNode]
          #   @return [Boolean]
          def_node_matcher :explicit_association?, <<~PATTERN
            (send nil? :association sym ...)
          PATTERN

          # @!method implicit_association?(node)
          #   @param node [RuboCop::AST::SendNode]
          #   @return [Boolean]
          def_node_matcher :implicit_association?, <<~PATTERN
            (send nil? !#non_implicit_association_method_name? ...)
          PATTERN

          # @!method factory_option_matcher(node)
          #   @param node [RuboCop::AST::SendNode]
          #   @return [Array<Symbol>, Symbol, nil]
          def_node_matcher :factory_option_matcher, <<~PATTERN
            (send
              nil?
              :association
              ...
              (hash
                <
                  (pair
                    (sym :factory)
                    {
                      (sym $_) |
                      (array (sym $_)*)
                    }
                  )
                  ...
                >
              )
            )
          PATTERN

          # @!method trait_arguments_matcher(node)
          #   @param node [RuboCop::AST::SendNode]
          #   @return [Array<Symbol>, nil]
          def_node_matcher :trait_arguments_matcher, <<~PATTERN
            (send nil? :association _ (sym $_)* ...)
          PATTERN

          # @!method trait_option_matcher(node)
          #   @param node [RuboCop::AST::SendNode]
          #   @return [Array<Symbol>, nil]
          def_node_matcher :trait_option_matcher, <<~PATTERN
            (send
              nil?
              :association
              ...
              (hash
                <
                  (pair
                    (sym :traits)
                    (array (sym $_)*)
                  )
                  ...
                >
              )
            )
          PATTERN

          # @param corrector [RuboCop::Cop::Corrector]
          # @param node [RuboCop::AST::SendNode]
          def autocorrect(corrector, node)
            case style
            when :explicit
              autocorrect_to_explicit_style(corrector, node)
            when :implicit
              autocorrect_to_implicit_style(corrector, node)
            end
          end

          # @param corrector [RuboCop::Cop::Corrector]
          # @param node [RuboCop::AST::SendNode]
          # @return [void]
          def autocorrect_to_explicit_style(corrector, node)
            arguments = [
              ":#{node.method_name}",
              *node.arguments.map(&:source)
            ]
            corrector.replace(node, "association #{arguments.join(', ')}")
          end

          # @param corrector [RuboCop::Cop::Corrector]
          # @param node [RuboCop::AST::SendNode]
          # @return [void]
          def autocorrect_to_implicit_style(corrector, node)
            source = node.first_argument.value.to_s
            options = options_for_autocorrect_to_implicit_style(node)
            unless options.empty?
              rest = options.map { |option| option.join(': ') }.join(', ')
              source += " #{rest}"
            end
            corrector.replace(node, source)
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Boolean]
          def autocorrectable_to_implicit_style?(node)
            node.arguments.one?
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Boolean]
          def bad?(node)
            case style
            when :explicit
              implicit_association?(node)
            when :implicit
              explicit_association?(node)
            end
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Array<RuboCop::AST::SendNode>]
          def bad_associations_in(node)
            children_of_factory_block(node).select do |child|
              bad?(child)
            end
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Array<RuboCop::AST::Node>]
          def children_of_factory_block(node)
            block = node.parent
            return [] unless block
            return [] unless block.block_type?
            return [] unless block.body

            if block.body.begin_type?
              block.body.children
            else
              [block.body]
            end
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Array<Symbol>]
          def factory_names_from_explicit(node)
            trait_names = trait_names_from_explicit(node)
            factory_names = Array(factory_option_matcher(node))
            result = factory_names + trait_names
            if factory_names.empty? && !trait_names.empty?
              result.prepend(node.first_argument.value)
            end
            result
          end

          # @param method_name [Symbol]
          # @return [Boolean]
          def non_implicit_association_method_name?(method_name)
            non_implicit_association_method_names.include?(method_name.to_s)
          end

          # @return [Array<String>]
          def non_implicit_association_method_names
            DEFAULT_NON_IMPLICIT_ASSOCIATION_METHOD_NAMES +
              (cop_config['NonImplicitAssociationMethodNames'] || [])
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Hash{Symbol => String}]
          def options_from_explicit(node)
            return {} unless node.last_argument.hash_type?

            node.last_argument.pairs.inject({}) do |options, pair|
              options.merge(pair.key.value => pair.value.source)
            end
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Hash{Symbol => String}]
          def options_for_autocorrect_to_implicit_style(node)
            options = options_from_explicit(node)
            options.delete(:traits)
            factory_names = factory_names_from_explicit(node)
            unless factory_names.empty?
              options[:factory] = "%i[#{factory_names.join(' ')}]"
            end
            options
          end

          # @param node [RuboCop::AST::SendNode]
          # @return [Array<Symbol>]
          def trait_names_from_explicit(node)
            (trait_arguments_matcher(node) || []) +
              (trait_option_matcher(node) || [])
          end
        end
      end
    end
  end
end
