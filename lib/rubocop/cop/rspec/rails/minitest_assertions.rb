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
        #   assert_nil a
        #   refute_empty(b)
        #
        #   # good
        #   expect(b).to eq(a)
        #   expect(b).to(eq(a), "must be equal")
        #   expect(b).not_to eq(a)
        #   expect(a).to eq(nil)
        #   expect(a).not_to be_empty
        #
        class MinitestAssertions < Base
          extend AutoCorrector

          MSG = 'Use `%<prefer>s`.'
          RESTRICT_ON_SEND = %i[
            assert_equal
            assert_not_equal
            assert_nil
            assert_not_nil
            assert_empty
            assert_not_empty
            refute_equal
            refute_nil
            refute_empty
          ].freeze

          # @!method minitest_equal(node)
          def_node_matcher :minitest_equal, <<~PATTERN
            (send nil? {:assert_equal :assert_not_equal :refute_equal} $_ $_ $_?)
          PATTERN

          # @!method minitest_nil(node)
          def_node_matcher :minitest_nil, <<~PATTERN
            (send nil? {:assert_nil :assert_not_nil :refute_nil} $_ $_?)
          PATTERN

          # @!method minitest_empty(node)
          def_node_matcher :minitest_empty, <<~PATTERN
            (send nil? {:assert_empty :assert_not_empty :refute_empty} $_ $_?)
          PATTERN

          def on_send(node) # rubocop:disable Metrics/MethodLength
            minitest_equal(node) do |expected, actual, failure_message|
              on_assertion(node, EqualAssertion.new(expected, actual,
                                                    failure_message.first))
            end

            minitest_nil(node) do |actual, failure_message|
              on_assertion(node, NilAssertion.new(actual,
                                                  failure_message.first))
            end

            minitest_empty(node) do |actual, failure_message|
              on_assertion(node, EmptyAssertion.new(actual,
                                                    failure_message.first))
            end
          end

          def on_assertion(node, assertion)
            preferred = assertion.replaced(node)
            add_offense(node, message: message(preferred)) do |corrector|
              corrector.replace(node, preferred)
            end
          end

          def message(preferred)
            format(MSG, prefer: preferred)
          end

          # :nodoc:
          class EqualAssertion
            def initialize(expected, actual, fail_message)
              @expected = expected
              @actual = actual
              @fail_message = fail_message
            end

            def replaced(node)
              runner = node.method?(:assert_equal) ? 'to' : 'not_to'
              if @fail_message.nil?
                "expect(#{@actual.source}).#{runner} eq(#{@expected.source})"
              else
                "expect(#{@actual.source}).#{runner}(eq(#{@expected.source})," \
                  " #{@fail_message.source})"
              end
            end
          end

          # :nodoc:
          class NilAssertion
            def initialize(actual, fail_message)
              @actual = actual
              @fail_message = fail_message
            end

            def replaced(node)
              runner = node.method?(:assert_nil) ? 'to' : 'not_to'
              if @fail_message.nil?
                "expect(#{@actual.source}).#{runner} eq(nil)"
              else
                "expect(#{@actual.source}).#{runner}(eq(nil), " \
                  "#{@fail_message.source})"
              end
            end
          end

          # :nodoc:
          class EmptyAssertion
            def initialize(actual, fail_message)
              @actual = actual
              @fail_message = fail_message
            end

            def replaced(node)
              runner = node.method?(:assert_empty) ? 'to' : 'not_to'
              if @fail_message.nil?
                "expect(#{@actual.source}).#{runner} be_empty"
              else
                "expect(#{@actual.source}).#{runner}(be_empty, " \
                  "#{@fail_message.source})"
              end
            end
          end
        end
      end
    end
  end
end
