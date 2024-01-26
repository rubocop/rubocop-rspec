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

            def negated?(node)
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

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_equal :assert_not_equal :refute_equal} $_ $_ $_?)
            PATTERN

            def self.match(expected, actual, failure_message)
              new(expected, actual, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_equal)
            end

            def assertion
              "eq(#{@expected})"
            end
          end

          # :nodoc:
          class InstanceOfAssertion < BasicAssertion
            MATCHERS = %i[
              assert_instance_of
              assert_not_instance_of
              refute_instance_of
            ].freeze

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_instance_of :assert_not_instance_of :refute_instance_of} $_ $_ $_?)
            PATTERN

            def self.match(expected, actual, failure_message)
              new(expected, actual, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_instance_of)
            end

            def assertion
              "be_an_instance_of(#{@expected})"
            end
          end

          # :nodoc:
          class IncludesAssertion < BasicAssertion
            MATCHERS = %i[
              assert_includes
              assert_not_includes
              refute_includes
            ].freeze

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_includes :assert_not_includes :refute_includes} $_ $_ $_?)
            PATTERN

            def self.match(collection, expected, failure_message)
              new(expected, collection, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_includes)
            end

            def assertion
              "include(#{@expected})"
            end
          end

          # :nodoc:
          class PredicateAssertion < BasicAssertion
            MATCHERS = %i[
              assert_predicate
              assert_not_predicate
              refute_predicate
            ].freeze

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_predicate :assert_not_predicate :refute_predicate} $_ ${sym} $_?)
            PATTERN

            def self.match(subject, predicate, failure_message)
              return nil unless predicate.value.end_with?('?')

              new(predicate, subject, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_predicate)
            end

            def assertion
              "be_#{@expected.delete_prefix(':').delete_suffix('?')}"
            end
          end

          # :nodoc:
          class MatchAssertion < BasicAssertion
            MATCHERS = %i[
              assert_match
              refute_match
            ].freeze

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_match :refute_match} $_ $_ $_?)
            PATTERN

            def self.match(matcher, actual, failure_message)
              new(matcher, actual, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_match)
            end

            def assertion
              "match(#{@expected})"
            end
          end

          # :nodoc:
          class NilAssertion < BasicAssertion
            MATCHERS = %i[
              assert_nil
              assert_not_nil
              refute_nil
            ].freeze

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_nil :assert_not_nil :refute_nil} $_ $_?)
            PATTERN

            def self.match(actual, failure_message)
              new(nil, actual, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_nil)
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

            NODE_MATCHER_PATTERN = <<~PATTERN
              (send nil? {:assert_empty :assert_not_empty :refute_empty} $_ $_?)
            PATTERN

            def self.match(actual, failure_message)
              new(nil, actual, failure_message.first)
            end

            def negated?(node)
              !node.method?(:assert_empty)
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

          ASSERTION_MATCHERS.each do |m|
            name = m.name.split('::').last

            def_node_matcher "minitest_#{name}".to_sym, m::NODE_MATCHER_PATTERN
          end

          def on_send(node)
            ASSERTION_MATCHERS.each do |m|
              name = m.name.split('::').last

              public_send("minitest_#{name}".to_sym, node) do |*args|
                assertion = m.match(*args)

                next if assertion.nil?

                on_assertion(node, assertion)
              end
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
