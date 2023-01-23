# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for passing a block by `pending` or `skip` within examples.
      #
      # @example
      #   # bad
      #   it 'does something' do
      #     pending 'not yet implemented' do
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   it 'does something' do
      #     pending 'not yet implemented'
      #     do_something
      #   end
      #
      #   # bad
      #   it 'does something' do
      #     skip 'not yet implemented' do
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   it 'does something' do
      #     skip 'not yet implemented'
      #     do_something
      #   end
      #
      #   # good - when outside example
      #   pending 'not yet implemented' do
      #   end
      #
      class PendingBlockInsideExample < Base
        MSG = "Don't pass a block to `pending` or `skip` inside examples."

        def on_block(node)
          return unless %i[pending skip].include?(node.method_name)
          return unless inside_example?(node)

          add_offense(node)
        end

        alias on_numblock on_block

        private

        def inside_example?(node)
          node.each_ancestor(:block).any? { |ancestor| example?(ancestor) }
        end
      end
    end
  end
end
