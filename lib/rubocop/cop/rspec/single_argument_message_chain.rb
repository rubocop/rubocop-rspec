module RuboCop
  module Cop
    module RSpec
      # Checks that chains of messages contain more than one element.
      #
      # @example
      #   # bad
      #   allow(foo).to receive_message_chain(:bar).and_return(42)
      #
      #   # good
      #   allow(foo).to receive(:bar).and_return(42)
      #
      #   # also good
      #   allow(foo).to receive(:bar, :baz)
      #   allow(foo).to receive("bar.baz")
      #
      class SingleArgumentMessageChain < Cop
        MESSAGE = 'Use `%<recommended_method>s` instead of calling ' \
          '`%<called_method>s` with a single argument'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless Matchers::MESSAGE_CHAIN.include?(method_name)
          return if args.size > 1
          return if multi_argument_string?(args)

          add_offense(node, :selector, message(method_name))
        end

        def autocorrect(node)
          _receiver, method_name, *_args = *node
          lambda do |corrector|
            corrector.replace(
              node.loc.selector,
              method_name.equal?(:receive_message_chain) ? 'receive' : 'stub'
            )
          end
        end

        private

        def multi_argument_string?(args)
          args.size == 1 &&
            args.first.type == :str &&
            args.first.children.first.include?('.')
        end

        def message(method)
          if method == :receive_message_chain
            MESSAGE % { recommended_method: :receive, called_method: method }
          else
            MESSAGE % { recommended_method: :stub, called_method: method }
          end
        end
      end
    end
  end
end
