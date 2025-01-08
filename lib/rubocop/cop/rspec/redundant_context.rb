# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Detect redundant `context` hook.
      #
      # @example
      #   # bad
      #   context 'when condition' do
      #     it 'tests something' do
      #     end
      #   end
      #
      #   # good
      #   it 'tests something when condition' do
      #   end
      #
      class RedundantContext < Base
        MSG = 'Redundant context with single example.'

        # @!method redundant_context?(node)
        def_node_matcher :redundant_context?, <<~PATTERN
          (block
            (send #rspec? :context _)
            _
            (block (send _ :it ...) ...))
        PATTERN

        def on_block(node)
          return unless redundant_context?(node)

          add_offense(node)
        end
        alias on_numblock on_block
      end
    end
  end
end
