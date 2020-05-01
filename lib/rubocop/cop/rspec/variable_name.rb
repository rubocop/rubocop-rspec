# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # This cop makes sure that all variables use the configured style.
      #
      # @example EnforcedStyle: snake_case (default)
      #   # bad
      #   let(:userName) { 'Adam' }
      #   subject(:userName) { 'Adam' }
      #
      #   # good
      #   let(:user_name) { 'Adam' }
      #   subject(:user_name) { 'Adam' }
      #
      # @example EnforcedStyle: camelCase
      #   # bad
      #   let(:user_name) { 'Adam' }
      #   subject(:user_name) { 'Adam' }
      #
      #   # good
      #   let(:userName) { 'Adam' }
      #   subject(:userName) { 'Adam' }
      class VariableName < Cop
        include ConfigurableNaming

        MSG = 'Use %<style>s for variable names.'

        def_node_matcher :variable_definition?, <<~PATTERN
          (send #{RSPEC} #{(Helpers::ALL + Subject::ALL).node_pattern_union}
            $({sym str} _) ...)
        PATTERN

        def on_send(node)
          variable_definition?(node) do |variable|
            check_name(node, variable.value, variable.loc.expression)
          end
        end

        private

        def message(style)
          format(MSG, style: style)
        end
      end
    end
  end
end
