# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Check if using Minitest matchers.
        #
        # @example
        #   # bad
        #   assert_equal(a, b)
        #   assert_equal a, b, "must be equal"
        #   refute_equal(a, b)
        #
        #   assert_nil a
        #   refute_nil a
        #
        #   # good
        #   expect(b).to eq(a)
        #   expect(b).to(eq(a), "must be equal")
        #   expect(b).not_to eq(a)
        #
        #   expect(a).to eq(nil)
        #   expect(a).not_to eq(nil)
        #
        class MinitestAssertions < Base
          extend AutoCorrector

          MSG = 'Use `%<prefer>s`.'
          RESTRICT_ON_SEND = %i[
            assert_equal
            assert_not_equal
            refute_equal
            assert_nil
            assert_not_nil
            refute_nil
          ].freeze

          # @!method minitest_equal_assertion(node)
          def_node_matcher :minitest_equal_assertion, <<~PATTERN
            (send nil? {:assert_equal :assert_not_equal :refute_equal} $_ $_ $_?)
          PATTERN

          # @!method minitest_nil_assertion(node)
          def_node_matcher :minitest_nil_assertion, <<~PATTERN
            (send nil? {:assert_nil :assert_not_nil :refute_nil} $_ $_?)
          PATTERN

          def on_send(node)
            minitest_equal_assertion(node) do |expected, actual, fail_message|
              prefer = replace_equal_assertion(node, expected, actual,
                                               fail_message.first)
              add_an_offense(node, prefer)
            end

            minitest_nil_assertion(node) do |actual, fail_message|
              prefer = replace_nil_assertion(node, actual,
                                             fail_message.first)
              add_an_offense(node, prefer)
            end
          end

          private

          def add_an_offense(node, prefer)
            add_offense(node, message: message(prefer)) do |corrector|
              corrector.replace(node, prefer)
            end
          end

          def replace_equal_assertion(node, expected, actual, failure_message)
            runner = node.method?(:assert_equal) ? 'to' : 'not_to'
            if failure_message.nil?
              "expect(#{actual.source}).#{runner} eq(#{expected.source})"
            else
              "expect(#{actual.source}).#{runner}(eq(#{expected.source}), " \
                "#{failure_message.source})"
            end
          end

          def replace_nil_assertion(node, actual, failure_message)
            runner = node.method?(:assert_nil) ? 'to' : 'not_to'
            if failure_message.nil?
              "expect(#{actual.source}).#{runner} eq(nil)"
            else
              "expect(#{actual.source}).#{runner}(eq(nil), " \
                "#{failure_message.source})"
            end
          end

          def message(prefer)
            format(MSG, prefer: prefer)
          end
        end
      end
    end
  end
end
