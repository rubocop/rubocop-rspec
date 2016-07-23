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
        MSG = 'Prefer using verifying doubles over normal doubles.'.freeze
        DOUBLE_TYPES = [:double, :spy].freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          name, *_stubs = *args
          return unless DOUBLE_TYPES.include?(method_name)
          return if name.nil?
          return if name_is_symbol?(name) && cop_config['IgnoreSymbolicNames']
          add_offense(node,
                      :expression,
                      format(MSG, node.loc.expression.source))
        end

        private

        def name_is_symbol?(name)
          name.children.first.is_a? Symbol
        end
      end
    end
  end
end
