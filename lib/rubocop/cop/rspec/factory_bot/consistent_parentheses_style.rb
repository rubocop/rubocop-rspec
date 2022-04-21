# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Use a consistent style for parentheses in factory bot calls.
        #
        # @example
        #
        #   # bad
        #   create :user
        #   build(:user)
        #   create(:login)
        #   create :login
        #
        # @example `EnforcedStyle: require_parentheses` (default)
        #
        #   # good
        #   create(:user)
        #   create(:user)
        #   create(:login)
        #   build(:login)
        #
        # @example `EnforcedStyle: omit_parentheses`
        #
        #   # good
        #   create :user
        #   build :user
        #   create :login
        #   create :login
        #
        class ConsistentParenthesesStyle < Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle
          include RuboCop::RSpec::FactoryBot::Language
          include RuboCop::Cop::Util

          def self.autocorrect_incompatible_with
            [Style::MethodCallWithArgsParentheses]
          end

          MSG_REQUIRE_PARENS = 'Prefer method call with parentheses'
          MSG_OMIT_PARENS = 'Prefer method call without parentheses'

          FACTORY_CALLS = RuboCop::RSpec::FactoryBot::Language::METHODS

          # @!method factory_call(node)
          def_node_matcher :factory_call, <<-PATTERN
              (send
                ${#factory_bot? nil?} %FACTORY_CALLS
              $...)
          PATTERN

          def on_send(node)
            return if nested_call?(node) # prevent from nested matching

            factory_call(node) do
              if node.parenthesized?
                process_with_parentheses(node)
              else
                process_without_parentheses(node)
              end
            end
          end

          def process_with_parentheses(node)
            return unless style == :omit_parentheses

            add_offense(node.loc.selector,
                        message: MSG_OMIT_PARENS) do |corrector|
              remove_parentheses(corrector, node)
            end
          end

          def process_without_parentheses(node)
            return unless style == :require_parentheses

            add_offense(node.loc.selector,
                        message: MSG_REQUIRE_PARENS) do |corrector|
              add_parentheses(node, corrector)
            end
          end

          def nested_call?(node)
            node.parent&.send_type?
          end

          private

          def remove_parentheses(corrector, node)
            corrector.replace(node.location.begin, ' ')
            corrector.remove(node.location.end)
          end
        end
      end
    end
  end
end
