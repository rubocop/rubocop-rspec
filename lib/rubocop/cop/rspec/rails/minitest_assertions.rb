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

          # :nodoc:
          class BasicAssertion
            extend NodePattern::Macros

            attr_reader :expected, :actual, :failure_message

            def initialize(node)
              @expected = nil
              @actual = nil
              @failure_message = nil
              match(node)
            end

            def expected=(expected)
              @expected = expected.source
            end

            def actual=(actual)
              @actual = actual.source
            end

            def failure_message=(failure_message)
              @failure_message = failure_message&.source
            end

            def match?
              !!actual
            end

            def replaced(node)
              runner = negated?(node) ? 'not_to' : 'to'
              if failure_message.nil?
                "expect(#{actual}).#{runner} #{assertion}"
              else
                "expect(#{actual}).#{runner}(#{assertion}, #{failure_message})"
              end
            end

            def negated?(node)
              node.method_name.start_with?('assert_not_', 'refute_')
            end

            def match(node)
              raise NotImplementedError
            end

            def assertion
              raise NotImplementedError
            end
          end

          # :nodoc:
          class EqualAssertion < BasicAssertion
            MATCHERS = %i[
              assert_equal
              assert_not_equal
              refute_equal
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_equal :assert_not_equal :refute_equal} $_ $_ $_?)
            PATTERN

            def match(node)
              pattern(node) do |expected, actual, failure_message|
                self.expected = expected
                self.actual = actual
                self.failure_message = failure_message.first
              end
            end

            def assertion
              "eq(#{expected})"
            end
          end

          # :nodoc:
          class InstanceOfAssertion < BasicAssertion
            MATCHERS = %i[
              assert_instance_of
              assert_not_instance_of
              refute_instance_of
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_instance_of :assert_not_instance_of :refute_instance_of} $_ $_ $_?)
            PATTERN

            def match(node)
              pattern(node) do |expected, actual, failure_message|
                self.expected = expected
                self.actual = actual
                self.failure_message = failure_message.first
              end
            end

            def assertion
              "be_an_instance_of(#{expected})"
            end
          end

          # :nodoc:
          class IncludesAssertion < BasicAssertion
            MATCHERS = %i[
              assert_includes
              assert_not_includes
              refute_includes
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_includes :assert_not_includes :refute_includes} $_ $_ $_?)
            PATTERN

            def match(node)
              pattern(node) do |collection, expected, failure_message|
                self.expected = expected
                self.actual = collection
                self.failure_message = failure_message.first
              end
            end

            def assertion
              "include(#{expected})"
            end
          end

          # :nodoc:
          class PredicateAssertion < BasicAssertion
            MATCHERS = %i[
              assert_predicate
              assert_not_predicate
              refute_predicate
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_predicate :assert_not_predicate :refute_predicate} $_ ${sym} $_?)
            PATTERN

            def match(node)
              pattern(node) do |subject, predicate, failure_message|
                return nil unless predicate.value.end_with?('?')

                self.expected = predicate
                self.actual = subject
                self.failure_message = failure_message.first
              end
            end

            def assertion
              "be_#{expected.delete_prefix(':').delete_suffix('?')}"
            end
          end

          # :nodoc:
          class MatchAssertion < BasicAssertion
            MATCHERS = %i[
              assert_match
              refute_match
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_match :refute_match} $_ $_ $_?)
            PATTERN

            def match(node)
              pattern(node) do |matcher, actual, failure_message|
                self.expected = matcher
                self.actual = actual
                self.failure_message = failure_message.first
              end
            end

            def assertion
              "match(#{expected})"
            end
          end

          # :nodoc:
          class NilAssertion < BasicAssertion
            MATCHERS = %i[
              assert_nil
              assert_not_nil
              refute_nil
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_nil :assert_not_nil :refute_nil} $_ $_?)
            PATTERN

            def match(node)
              pattern(node) do |actual, failure_message|
                self.actual = actual
                self.failure_message = failure_message.first
              end
            end

            def assertion
              'eq(nil)'
            end
          end

          # :nodoc:
          class EmptyAssertion < BasicAssertion
            MATCHERS = %i[
              assert_empty
              assert_not_empty
              refute_empty
            ].freeze

            # @!method pattern(node)
            def_node_matcher :pattern, <<~PATTERN
              (send nil? {:assert_empty :assert_not_empty :refute_empty} $_ $_?)
            PATTERN

            def match(node)
              pattern(node) do |actual, failure_message|
                self.actual = actual
                self.failure_message = failure_message.first
              end
            end

            def assertion
              'be_empty'
            end
          end

          MSG = 'Use `%<prefer>s`.'

          # TODO: replace with `BasicAssertion.subclasses` in Ruby 3.1+
          ASSERTION_MATCHERS = constants(false).filter_map do |c|
            const = const_get(c)

            const if const.is_a?(Class) && const.superclass == BasicAssertion
          end

          RESTRICT_ON_SEND = ASSERTION_MATCHERS.flat_map { |m| m::MATCHERS }

          def on_send(node)
            ASSERTION_MATCHERS.each do |matcher|
              assertion = matcher.new(node)
              on_assertion(node, assertion) if assertion.match?
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
        end
      end
    end
  end
end
