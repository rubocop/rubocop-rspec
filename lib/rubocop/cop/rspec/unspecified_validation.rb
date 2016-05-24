# encoding: utf-8

module RuboCop
  module Cop
    module RSpec
      # Specify validation fields in expectations
      #
      # @example
      #   # bad
      #   it '...' do
      #     expect(subject).to be_valid
      #   end
      #
      #   # good
      #   it '...' do
      #     expect(subject).to be_valid_for(:field)
      #   end
      class UnspecifiedValidation < Cop
        MSG = 'Specify field(s) for validation.'.freeze

        VALIDATION_EXPECTATIONS = [:be_valid, :be_invalid].freeze

        def on_send(node)
          _receiver, method_name, *_args = *node
          return unless VALIDATION_EXPECTATIONS.include?(method_name)

          add_offense(node, :expression, MSG)
        end

        def autocorrect(_node)
          false
        end
      end
    end
  end
end
