# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if examples contain too many `expect` calls.
      #
      # @see http://betterspecs.org/#single Single expectation test
      #
      # This cop is configurable using the `Max` option
      # and works with `--auto-gen-config`.
      #
      # @example
      #
      #   # bad
      #   describe UserCreator do
      #     it 'builds a user' do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      #   # good
      #   describe UserCreator do
      #     it 'sets the users name' do
      #       expect(user.name).to eq("John")
      #     end
      #
      #     it 'sets the users age' do
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example `aggregate_failures: true` (default)
      #
      #  # good - the cop ignores when RSpec aggregates failures
      #   describe UserCreator do
      #     it 'builds a user', :aggregate_failures do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example `aggregate_failures: false`
      #
      #  # Detected as an offense
      #   describe UserCreator do
      #     it 'builds a user', aggregate_failures: false do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example configuration
      #
      #   # .rubocop.yml
      #   # RSpec/MultipleExpectations:
      #   #   Max: 2
      #
      #   # not flagged by rubocop
      #   describe UserCreator do
      #     it 'builds a user' do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      class MultipleExpectations < Base
        include ConfigurableMax

        MSG = 'Example has too many expectations [%<total>d/%<max>d].'

        ANYTHING = ->(_node) { true }
        TRUE = ->(node) { node.true_type? }

        # @!method aggregate_failures?(node)
        def_node_matcher :aggregate_failures?, <<-PATTERN
          (block {
              (send _ _ <(sym :aggregate_failures) ...>)
              (send _ _ ... (hash <(pair (sym :aggregate_failures) %1) ...>))
            } ...)
        PATTERN

        # @!method expect?(node)
        def_node_matcher :expect?, send_pattern('#Expectations.all')
        # @!method aggregate_failures_block?(node)
        def_node_matcher :aggregate_failures_block?, <<-PATTERN
          (block (send nil? :aggregate_failures ...) ...)
        PATTERN

        def on_block(node)
          return unless example?(node)
          return if example_with_aggregate_failures?(node)

          total = expectation_count(node)
          return if total <= max_expectations

          self.max = total
          flag_example(node, total: total)
        end

        private

        def example_with_aggregate_failures?(example_node)
          node_with_aggregate_failures = find_aggregate_failures(example_node)
          return false unless node_with_aggregate_failures

          aggregate_failures?(node_with_aggregate_failures, TRUE)
        end

        def find_aggregate_failures(example_node)
          example_node.send_node.each_ancestor(:block)
            .find { |block_node| aggregate_failures?(block_node, ANYTHING) }
        end

        def expectation_count(node, count = 0)
          # do not search  inside of aggregate_failures blocks
          return count if aggregate_failures_block?(node)

          if node.if_type? || node.case_type?
            return expectation_count_max(node, count)
          end

          expectation_count_aggregate(node, count)
        end

        def expectation_count_max(node, count)
          node.each_child_node.map do |child|
            expectation_count(child, count)
          end.max
        end

        def expectation_count_aggregate(node, count)
          node.each_child_node do |child|
            count = if expect?(child) || aggregate_failures_block?(child)
                      expectation_count(child, count + 1)
                    else
                      expectation_count(child, count)
                    end
          end
          count
        end

        def flag_example(node, total:)
          add_offense(
            node.send_node,
            message: format(
              MSG,
              total: total,
              max: max_expectations
            )
          )
        end

        def max_expectations
          Integer(cop_config.fetch('Max', 1))
        end
      end
    end
  end
end
