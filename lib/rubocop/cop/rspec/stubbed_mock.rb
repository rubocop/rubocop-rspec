# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that message expectations are not combined with message stubs.
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
      class StubbedMock < Base
        MSG = 'Do not stub your mock.'

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

        def self.expectation_with(matcher)
          <<~PATTERN
            (send
              (send nil? #{Expectations::ALL.node_pattern_union} ...)
              :to #{matcher}
            )
          PATTERN
        end

        def_node_matcher :expectation_with_configured_response,
                         expectation_with(<<~PATTERN)
                           $(send #message_expectation? #configured_response? _)
                         PATTERN

        def_node_matcher :expectation_with_return_block,
                         expectation_with(<<~PATTERN)
                           $(block #message_expectation? args _)
                         PATTERN

        def_node_matcher :expectation_with_blockpass,
                         expectation_with(<<~PATTERN)
                           {
                             (send nil? { :receive :receive_message_chain } ... $block_pass)
                             (send (send nil? :receive ...) :with ... $block_pass)
                           }
                         PATTERN

        def_node_matcher :expectation_with_hash,
                         expectation_with(<<~PATTERN)
                           {
                             (send nil? :receive_messages $hash)
                             (send nil? :receive_message_chain ... $hash)
                           }
                         PATTERN

        def on_send(node)
          expectation_with_configured_response(node) do |match|
            add_offense(offending_range(match.loc, match.loc.dot))
          end

          expectation_with_return_block(node) do |match|
            add_offense(offending_range(match.loc, match.loc.begin))
          end

          expectation_with_hash(node, &method(:add_offense))

          expectation_with_blockpass(node, &method(:add_offense))
        end

        private

        def offending_range(source_map, begin_range)
          Parser::Source::Range.new(
            source_map.expression.source_buffer,
            begin_range.begin_pos,
            source_map.expression.end_pos
          )
        end
      end
    end
  end
end
