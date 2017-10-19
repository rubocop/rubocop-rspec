# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Prefer using verifying doubles over normal doubles.
      #
      # @see https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles
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

        def_node_matcher :unverified_double, <<-PATTERN
          {(send nil? {:double :spy} $_ ...) }
        PATTERN

        def on_send(node)
          unverified_double(node) do |name|
            return if name.sym_type? && cop_config['IgnoreSymbolicNames']

            add_offense(node, location: :expression)
          end
        end
      end
    end
  end
end
