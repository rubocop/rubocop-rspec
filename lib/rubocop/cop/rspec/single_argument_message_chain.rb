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
        MSG = 'Use `%<recommended>s` instead of calling '\
              '`%<called>s` with a single argument.'.freeze

        def_node_matcher :message_chain, <<-PATTERN
          (send _ #{Matchers::MESSAGE_CHAIN.node_pattern_union} $...)
        PATTERN

        def on_send(node)
          message_chain(node) do |(first, *remaining)|
            return if first.to_s.include?('.') || remaining.any?

            add_offense(node, :selector)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector, replacement(node.method_name))
          end
        end

        private

        def replacement(method)
          method.equal?(:receive_message_chain) ? 'receive' : 'stub'
        end

        def message(node)
          method = node.method_name

          format(MSG, recommended: replacement(method), called: method)
        end
      end
    end
  end
end
