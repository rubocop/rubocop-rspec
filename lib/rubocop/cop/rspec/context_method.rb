# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # `context` should not be used for specifying methods.
      #
      # @example
      #   # bad
      #   context '#foo_bar' do
      #     # ...
      #   end
      #
      #   context '.foo_bar' do
      #     # ...
      #   end
      #
      #   # good
      #   describe '#foo_bar' do
      #     # ...
      #   end
      #
      #   describe '.foo_bar' do
      #     # ...
      #   end
      #
      class ContextMethod < Base
        extend AutoCorrector

        MSG = 'Use `describe` for testing methods.'

        # @!method context_method(node)
        def_node_matcher :context_method, <<~PATTERN
          {
            (block
              (send #rspec? :context
                ${(str #method_name?) (dstr (str #method_name?) ...)}
              ...)
            ...)
            (send #rspec? :context
              ${(str #method_name?) (dstr (str #method_name?) ...)}
            ... block_pass)
          }
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          context_method(node) do |context|
            add_offense(context) do |corrector|
              corrector.replace(send_node(node).loc.selector, 'describe')
            end
          end
        end
        alias on_send on_block

        private

        def send_node(node)
          node.send_type? ? node : node.send_node
        end

        def method_name?(description)
          description.start_with?('.', '#')
        end
      end
    end
  end
end
