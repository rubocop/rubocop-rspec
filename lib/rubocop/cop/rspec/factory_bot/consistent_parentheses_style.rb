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
        #   build(:user)
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
        #   # also good
        #   # when method name and first argument are not on same line
        #   create(
        #     :user
        #   )
        #   build(
        #     :user,
        #     name: 'foo'
        #   )
        #
        # @example `ExplicitOnly: false` (default)
        #
        #   # bad - with `EnforcedStyle: require_parentheses`
        #   FactoryBot.create :user
        #   build :user
        #
        #   # good - with `EnforcedStyle: require_parentheses`
        #   FactoryBot.create(:user)
        #   build(:user)
        #
        # @example `ExplicitOnly: true`
        #
        #   # bad - with `EnforcedStyle: require_parentheses`
        #   FactoryBot.create :user
        #   FactoryBot.build :user
        #
        #   # good - with `EnforcedStyle: require_parentheses`
        #   FactoryBot.create(:user)
        #   FactoryBot.build(:user)
        #   create :user
        #   build :user
        #
        class ConsistentParenthesesStyle < ::RuboCop::Cop::Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle
          include ConfigurableExplicitOnly

          MSG_REQUIRE_PARENS = 'Prefer method call with parentheses'
          MSG_OMIT_PARENS = 'Prefer method call without parentheses'
          FACTORY_CALLS = RuboCop::RSpec::FactoryBot::Language::METHODS
          RESTRICT_ON_SEND = FACTORY_CALLS

          # @!method factory_call(node)
          def_node_matcher :factory_call, <<-PATTERN
            (send
              #factory_call? %FACTORY_CALLS
              {sym str send lvar} _*
            )
          PATTERN

          def self.autocorrect_incompatible_with
            [Style::MethodCallWithArgsParentheses]
          end

          def on_send(node)
            return if ambiguous_without_parentheses?(node)

            factory_call(node) { register_offense(node) }
          end

          private

          def register_offense(node)
            return if node.method?(:generate) && node.arguments.count > 1

            register_offense_with_parentheses(node)
            register_offense_without_parentheses(node)
          end

          def register_offense_with_parentheses(node)
            return if style == :require_parentheses || !node.parenthesized?
            return unless same_line?(node, node.first_argument)

            add_offense(node.loc.selector,
                        message: MSG_OMIT_PARENS) do |corrector|
              remove_parentheses(corrector, node)
            end
          end

          def register_offense_without_parentheses(node)
            return if style == :omit_parentheses || node.parenthesized?

            add_offense(node.loc.selector,
                        message: MSG_REQUIRE_PARENS) do |corrector|
              add_parentheses(node, corrector)
            end
          end

          def ambiguous_without_parentheses?(node)
            node.parent&.send_type? ||
              node.parent&.pair_type? ||
              node.parent&.array_type?
          end

          def remove_parentheses(corrector, node)
            corrector.replace(node.location.begin, ' ')
            corrector.remove(node.location.end)
          end
        end
      end
    end
  end
end
