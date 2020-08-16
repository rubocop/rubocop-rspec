# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that message expectations do not have a configured response.
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
        MSG = 'Prefer `%<replacement>s` to `%<method_name>s` when ' \
              'configuring a response.'

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
              $(send nil? $#{Expectations::ALL.node_pattern_union} ...)
              :to #{matcher}
            )
          PATTERN
        end

        def_node_matcher :expectation_with_configured_response,
                         expectation_with(<<~PATTERN)
                           (send #message_expectation? #configured_response? _)
                         PATTERN

        def_node_matcher :expectation_with_return_block,
                         expectation_with(<<~PATTERN)
                           (block #message_expectation? args _)
                         PATTERN

        def_node_matcher :expectation_with_blockpass_or_hash,
                         expectation_with(<<~PATTERN)
                           {
                             (send nil? { :receive :receive_message_chain } ... block_pass)
                             (send (send nil? :receive ...) :with ... block_pass)
                             (send nil? :receive_messages hash)
                             (send nil? :receive_message_chain ... hash)
                           }
                         PATTERN

        def on_send(node)
          expectation_with_configured_response(node) do |match, method_name|
            add_offense(match, message: msg(method_name))
          end

          expectation_with_return_block(node) do |match, method_name|
            add_offense(match, message: msg(method_name))
          end

          expectation_with_blockpass_or_hash(node) do |match, method_name|
            add_offense(match, message: msg(method_name))
          end
        end

        private

        def msg(method_name)
          format(MSG,
                 method_name: method_name,
                 replacement: replacement(method_name))
        end

        def replacement(method_name)
          case method_name
          when :expect
            :allow
          when :is_expected
            'allow(subject)'
          when :expect_any_instance_of
            :allow_any_instance_of
          end
        end
      end
    end
  end
end
