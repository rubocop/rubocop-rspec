module RuboCop
  module Cop
    module RSpec
      # Check that chains of messages are not being stubbed.
      #
      # @example
      #   # bad
      #   allow(foo).to receive_message_chain(:bar, :baz).and_return(42)
      #
      #   # better
      #   thing = Thing.new(baz: 42)
      #   allow(foo).to receive(bar: thing)
      #
      class MessageChain < Cop
        MESSAGE = 'Avoid stubbing using `%<method>s`'.freeze

        def on_send(node)
          _receiver, method_name, *_args = *node
          return unless Matchers::MESSAGE_CHAIN.include?(method_name)

          add_offense(node, :selector, MESSAGE % { method: method_name })
        end
      end
    end
  end
end
