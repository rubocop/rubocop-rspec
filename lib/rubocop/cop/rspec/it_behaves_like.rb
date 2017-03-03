# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that only one `it_behaves_like` style is used.
      #
      # @example when configuration is `EnforcedStyle: it_behaves_like`
      #   # bad
      #   it_should_behave_like 'a foo'
      #
      #   # good
      #   it_behaves_like 'a foo'
      #
      # @example when configuration is `EnforcedStyle: it_should_behave_like`
      #   # bad
      #   it_behaves_like 'a foo'
      #
      #   # good
      #   it_should_behave_like 'a foo'
      class ItBehavesLike < Cop
        include ConfigurableEnforcedStyle

        MESSAGE = 'Prefer `%s` over `%s` when including examples in '\
                  'a nested context.'.freeze

        def on_send(node)
          return unless example_inclusion_offense?(node)

          add_offense(node, :expression, message)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, style.to_s) }
        end

        private

        def example_inclusion_offense?(node)
          supported_styles.include?(node.method_name) &&
            !node.method_name.equal?(style)
        end

        def message
          format(MESSAGE, style, alternative_style)
        end

        private_constant(*constants(false))
      end
    end
  end
end
