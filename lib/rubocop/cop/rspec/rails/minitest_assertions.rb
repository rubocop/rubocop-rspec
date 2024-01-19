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
        #   assert_not_includes a, b
        #   refute_equal(a, b)
        #   assert_nil a
        #   refute_empty(b)
        #
        #   # good
        #   expect(b).to eq(a)
        #   expect(b).to(eq(a), "must be equal")
        #   expect(a).not_to include(b)
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
            assert_instance_of
            assert_not_instance_of
            assert_includes
            assert_not_includes
            assert_match
            assert_nil
            assert_not_nil
            assert_empty
            assert_not_empty
            refute_equal
            refute_instance_of
            refute_includes
            refute_nil
            refute_empty
            refute_match
          ].freeze

          # @!method minitest_equal(node)
          def_node_matcher :minitest_equal, <<~PATTERN
            (send nil? {:assert_equal :assert_not_equal :refute_equal} $_ $_ $_?)
          PATTERN

          # @!method minitest_instance_of(node)
          def_node_matcher :minitest_instance_of, <<~PATTERN
            (send nil? {:assert_instance_of :assert_not_instance_of :refute_instance_of} $_ $_ $_?)
          PATTERN

          # @!method minitest_includes(node)
          def_node_matcher :minitest_includes, <<~PATTERN
            (send nil? {:assert_includes :assert_not_includes :refute_includes} $_ $_ $_?)
          PATTERN

          # @!method minitest_match(node)
          def_node_matcher :minitest_match, <<~PATTERN
            (send nil? {:assert_match :refute_match} $_ $_ $_?)
          PATTERN

          # @!method minitest_nil(node)
          def_node_matcher :minitest_nil, <<~PATTERN
            (send nil? {:assert_nil :assert_not_nil :refute_nil} $_ $_?)
          PATTERN

          # @!method minitest_empty(node)
          def_node_matcher :minitest_empty, <<~PATTERN
            (send nil? {:assert_empty :assert_not_empty :refute_empty} $_ $_?)
          PATTERN

          def on_send(node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            minitest_equal(node) do |expected, actual, failure_message|
              on_assertion(node, EqualAssertion.new(expected, actual,
                                                    failure_message.first))
            end

            minitest_instance_of(node) do |expected, actual, failure_message|
              on_assertion(node, InstanceOfAssertion.new(expected, actual,
                                                         failure_message.first))
            end

            minitest_includes(node) do |collection, expected, failure_message|
              on_assertion(node, IncludesAssertion.new(expected, collection,
                                                       failure_message.first))
            end

            minitest_match(node) do |matcher, actual, failure_message|
              on_assertion(node, MatchAssertion.new(matcher, actual,
                                                    failure_message.first))
            end

            minitest_nil(node) do |actual, failure_message|
              on_assertion(node, NilAssertion.new(nil, actual,
                                                  failure_message.first))
            end

            minitest_empty(node) do |actual, failure_message|
              on_assertion(node, EmptyAssertion.new(nil, actual,
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
          class BasicAssertion
            def initialize(expected, actual, fail_message)
              @expected = expected&.source
              @actual = actual.source
              @fail_message = fail_message&.source
            end

            def replaced(node)
              runner = negated?(node) ? 'not_to' : 'to'
              if @fail_message.nil?
                "expect(#{@actual}).#{runner} #{assertion}"
              else
                "expect(#{@actual}).#{runner}(#{assertion}, #{@fail_message})"
              end
            end
          end

          # :nodoc:
          class EqualAssertion < BasicAssertion
            def negated?(node)
              !node.method?(:assert_equal)
            end

            def assertion
              "eq(#{@expected})"
            end
          end

          # :nodoc:
          class InstanceOfAssertion < BasicAssertion
            def negated?(node)
              !node.method?(:assert_instance_of)
            end

            def assertion
              "be_an_instance_of(#{@expected})"
            end
          end

          # :nodoc:
          class IncludesAssertion < BasicAssertion
            def negated?(node)
              !node.method?(:assert_includes)
            end

            def assertion
              "include(#{@expected})"
            end
          end

          # :nodoc:
          class MatchAssertion < BasicAssertion
            def negated?(node)
              !node.method?(:assert_match)
            end

            def assertion
              "match(#{@expected})"
            end
          end

          # :nodoc:
          class NilAssertion < BasicAssertion
            def negated?(node)
              !node.method?(:assert_nil)
            end

            def assertion
              'eq(nil)'
            end
          end

          # :nodoc:
          class EmptyAssertion < BasicAssertion
            def negated?(node)
              !node.method?(:assert_empty)
            end

            def assertion
              'be_empty'
            end
          end
        end
      end
    end
  end
end
