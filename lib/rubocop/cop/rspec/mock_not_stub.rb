# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that stubs aren't added to mocks.
      #
      # @example
      #
      #   # bad
      #   expect(foo).to receive(:bar).with(42).and_return("hello world")
      #
      #   # good (without spies)
      #   allow(foo).to receive(:bar).with(42).and_return("hello world")
      #   expect(foo).to receive(:bar).with(42)
      #
      class MockNotStub < Cop
        MSG = "Don't stub your mock.".freeze

        def_node_matcher :message_expectation?, <<-PATTERN
          {
            (send nil? { :receive :receive_message_chain } ...)
            (send (send nil? :receive ...) :with ...)
          }
        PATTERN

        def_node_matcher :configured_response?, <<~PATTERN
          { :and_return :and_raise :and_throw :and_yield
            :and_call_original :and_wrap_original }
        PATTERN

        def_node_matcher :message_expectation_with_configured_response,
        <<~PATTERN
          (send
            (send nil? :expect ...) :to
            $(send #message_expectation? #configured_response? _)
          )
        PATTERN

        def_node_matcher :message_expectation_with_return_block, <<~PATTERN
          (send
            (send nil? :expect ...) :to
            $(block #message_expectation? args _)
          )
        PATTERN

        def_node_matcher :messages_expectation_with_configured_hash_response,
        <<~PATTERN
          (send
            (send nil? :expect ...) :to
            {
              (send nil? :receive_messages $hash)
              (send nil? :receive_message_chain ... $hash)
            }
          )
        PATTERN

        def on_send(node)
          message_expectation_with_configured_response(node) do |match|
            add_offense(offending_argument_range(match.loc))
          end

          message_expectation_with_return_block(node) do |match|
            add_offense(offending_block_range(match.loc))
          end

          messages_expectation_with_configured_hash_response(node) do |match|
            add_offense(match)
          end
        end

        def offending_argument_range(source_map)
          Parser::Source::Range.new(
            source_map.expression.source_buffer,
            source_map.dot.begin_pos,
            source_map.end.end_pos
          )
        end

        def offending_block_range(source_map)
          Parser::Source::Range.new(
            source_map.expression.source_buffer,
            source_map.begin.begin_pos,
            source_map.end.end_pos
          )
        end
      end
    end
  end
end
