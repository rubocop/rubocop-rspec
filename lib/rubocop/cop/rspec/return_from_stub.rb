# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent style of stub's return setting.
      #
      # Enforces either `and_return` or block-style return in the cases
      # where the returned value is constant. Ignores dynamic returned values
      # are the result would be different
      #
      # This cop can be configured using the `EnforcedStyle` option
      #
      # @example `EnforcedStyle: block`
      #   # bad
      #   allow(Foo).to receive(:bar).and_return("baz")
      #   expect(Foo).to receive(:bar).and_return("baz")
      #
      #   # good
      #   allow(Foo).to receive(:bar) { "baz" }
      #   expect(Foo).to receive(:bar) { "baz" }
      #   # also good as the returned value is dynamic
      #   allow(Foo).to receive(:bar).and_return(bar.baz)
      #
      # @example `EnforcedStyle: and_return`
      #   # bad
      #   allow(Foo).to receive(:bar) { "baz" }
      #   expect(Foo).to receive(:bar) { "baz" }
      #
      #   # good
      #   allow(Foo).to receive(:bar).and_return("baz")
      #   expect(Foo).to receive(:bar).and_return("baz")
      #   # also good as the returned value is dynamic
      #   allow(Foo).to receive(:bar) { bar.baz }
      #
      class ReturnFromStub < Cop
        include ConfigurableEnforcedStyle

        MSG_AND_RETURN = 'Use `and_return` for static values.'.freeze
        MSG_BLOCK = 'Use block for static values.'.freeze

        def_node_matcher :and_return_value, <<-PATTERN
            (send
              (send nil? :receive (...)) :and_return $(...)
            )
        PATTERN

        def on_send(node)
          if style == :block
            check_and_return_call(node)
          elsif node.method_name == :receive
            check_block_body(node)
          end
        end

        def autocorrect(node)
          if style == :block
            AndReturnCallCorrector.new(node)
          else
            BlockBodyCorrector.new(node)
          end
        end

        private

        def check_and_return_call(node)
          and_return_value(node) do |args|
            unless dynamic?(args)
              add_offense(
                node,
                location: :expression,
                message: MSG_BLOCK
              )
            end
          end
        end

        def check_block_body(node)
          block = node.each_ancestor(:block).first
          return unless block

          _receiver, _args, body = *block
          unless body && dynamic?(body) # rubocop:disable Style/GuardClause
            add_offense(
              node,
              location: :expression,
              message: MSG_AND_RETURN
            )
          end
        end

        def dynamic?(node)
          !node.recursive_literal?
        end

        # :nodoc:
        class AndReturnCallCorrector
          def initialize(node)
            @node = node
            @receiver, _method_name, @args = *node
          end

          def call(corrector)
            # Heredoc autocorrection is not yet implemented.
            return if heredoc?

            corrector.replace(range, " { #{replacement} }")
          end

          private

          attr_reader :node, :receiver, :args

          def heredoc?
            args.loc.is_a?(Parser::Source::Map::Heredoc)
          end

          def range
            Parser::Source::Range.new(
              node.source_range.source_buffer,
              receiver.source_range.end_pos,
              node.source_range.end_pos
            )
          end

          def replacement
            if hash_without_braces?
              "{ #{args.source} }"
            else
              args.source
            end
          end

          def hash_without_braces?
            args.hash_type? && !args.braces?
          end
        end

        # :nodoc:
        class BlockBodyCorrector
          def initialize(node)
            @block = node.each_ancestor(:block).first
            @node = node
            @body = block.body || NULL_BLOCK_BODY
          end

          def call(corrector)
            # Heredoc autocorrection is not yet implemented.
            return if heredoc?

            corrector.replace(range, ".and_return(#{body.source})")
          end

          private

          attr_reader :node, :block, :body

          def range
            Parser::Source::Range.new(
              block.source_range.source_buffer,
              node.source_range.end_pos,
              block.source_range.end_pos
            )
          end

          def heredoc?
            body.loc.is_a?(Parser::Source::Map::Heredoc)
          end

          NULL_BLOCK_BODY = Struct.new(:loc, :source).new(nil, 'nil')
        end
      end
    end
  end
end
