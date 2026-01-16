# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent style of change matcher.
      #
      # Enforces either passing a receiver and message as method arguments,
      # or a block.
      #
      # This cop can be configured using the `EnforcedStyle` option.
      #
      # When using compound expectations with `change` and a negated matcher
      # (e.g., `not_change`), you can configure the `NegatedMatcher` option
      # to ensure consistent style enforcement across both matchers.
      #
      # @safety
      #   Autocorrection is unsafe because `method_call` style calls the
      #   receiver *once* and sends the message to it before and after
      #   calling the `expect` block, whereas `block` style calls the
      #   expression *twice*, including the receiver.
      #
      #   If your receiver is dynamic (e.g., the result of a method call) and
      #   you expect it to be called before and after the `expect` block,
      #   changing from `block` to `method_call` style may break your test.
      #
      #   [source,ruby]
      #   ----
      #   expect { run }.to change { my_method.message }
      #   # `my_method` is called before and after `run`
      #
      #   expect { run }.to change(my_method, :message)
      #   # `my_method` is called once, but `message` is called on it twice
      #   ----
      #
      # @example `EnforcedStyle: method_call` (default)
      #   # bad
      #   expect { run }.to change { Foo.bar }
      #   expect { run }.to change { foo.baz }
      #
      #   # good
      #   expect { run }.to change(Foo, :bar)
      #   expect { run }.to change(foo, :baz)
      #   # also good when there are arguments or chained method calls
      #   expect { run }.to change { Foo.bar(:count) }
      #   expect { run }.to change { user.reload.name }
      #
      # @example `EnforcedStyle: block`
      #   # bad
      #   expect { run }.to change(Foo, :bar)
      #
      #   # good
      #   expect { run }.to change { Foo.bar }
      #
      # @example `NegatedMatcher: not_change` (with compound expectations)
      #   # bad
      #   expect { run }.to change(Foo, :bar).and not_change { Foo.baz }
      #
      #   # good
      #   expect { run }.to change(Foo, :bar).and not_change(Foo, :baz)
      #
      class ExpectChange < Base
        extend AutoCorrector
        include ConfigurableEnforcedStyle

        MSG_BLOCK = 'Prefer `%<matcher>s(%<obj>s, :%<attr>s)`.'
        MSG_CALL = 'Prefer `%<matcher>s { %<obj>s.%<attr>s }`.'

        # @!method expect_matcher_with_arguments(node)
        def_node_matcher :expect_matcher_with_arguments, <<~PATTERN
          (send nil? _ $_ ({sym str} $_))
        PATTERN

        # @!method expect_matcher_with_block(node)
        def_node_matcher :expect_matcher_with_block, <<~PATTERN
          (block
            (send nil? _)
            (args)
            (send
              ${
                (send nil? _)  # change { user.name }
                const          # change { User.count }
              }
              $_
            )
          )
        PATTERN

        def on_send(node)
          return unless style == :block
          return unless matcher_method?(node.method_name)

          expect_matcher_with_arguments(node) do |receiver, message|
            matcher_name = node.method_name.to_s
            msg = format(MSG_CALL, matcher: matcher_name,
                                   obj: receiver.source, attr: message)
            add_offense(node, message: msg) do |corrector|
              replacement = "#{matcher_name} { #{receiver.source}.#{message} }"
              corrector.replace(node, replacement)
            end
          end
        end

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless style == :method_call
          return unless matcher_method?(node.method_name)

          expect_matcher_with_block(node) do |receiver, message|
            matcher_name = node.method_name.to_s
            msg = format(MSG_BLOCK, matcher: matcher_name,
                                    obj: receiver.source, attr: message)
            add_offense(node, message: msg) do |corrector|
              replacement = "#{matcher_name}(#{receiver.source}, :#{message})"
              corrector.replace(node, replacement)
            end
          end
        end

        private

        def matcher_method_names
          @matcher_method_names ||= begin
            names = [:change]
            names << negated_matcher.to_sym if negated_matcher
            names
          end
        end

        def matcher_method?(method_name)
          matcher_method_names.include?(method_name)
        end

        def negated_matcher
          cop_config['NegatedMatcher']
        end
      end
    end
  end
end
