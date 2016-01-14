# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Prefer using verifying doubles over normal doubles.
      # see: https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles
      #
      # @example
      #   # bad
      #   it '...' do
      #     widget = double("Widget")
      #   end
      #
      #   # good
      #   it '...' do
      #     widget = instance_double("Widget")
      #   end
      class VerifiedDoubles < Cop
        MSG = 'Prefer using verifying doubles over normal doubles.'

        def on_send(node)
          _receiver, method_name, *_args = *node
          return unless method_name == :double
          add_offense(node,
                      :expression,
                      format(MSG, node.loc.expression.source))
        end
      end
    end
  end
end
