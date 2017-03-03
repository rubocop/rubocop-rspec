module RuboCop
  module Cop
    module RSpec
      # Checks for consistent method usage for negating expectations.
      #
      # @example
      #   # bad
      #   it '...' do
      #     expect(false).to_not be_true
      #   end
      #
      #   # good
      #   it '...' do
      #     expect(false).not_to be_true
      #   end
      class NotToNot < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Prefer `%s` over `%s`'.freeze

        METHOD_NAMES = [:not_to, :to_not].freeze

        def on_send(node)
          _receiver, method_name, *_args = *node

          return unless METHOD_NAMES.include?(method_name)

          return if style.equal?(method_name)
          add_offense(node, :expression)
        end

        def message(node)
          _receiver, method_name, *_args = *node

          if method_name.equal?(:not_to)
            format(MSG, 'to_not', 'not_to')
          else
            format(MSG, 'not_to', 'to_not')
          end
        end

        def autocorrect(node)
          _receiver, method_name, *_args = *node
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              method_name.equal?(:not_to) ? 'to_not' : 'not_to')
          end
        end
      end
    end
  end
end
