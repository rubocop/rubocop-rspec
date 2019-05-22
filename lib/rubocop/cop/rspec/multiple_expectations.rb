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
      class MultipleExpectations < Cop
        include ConfigurableMax

        MSG = 'Example has too many expectations [%<total>d/%<max>d].'

        def_node_search :with_aggregate_failures?, '(sym :aggregate_failures)'
        def_node_search :disabled_aggregate_failures?, <<-PATTERN
          (pair (sym :aggregate_failures) (false))
        PATTERN

        def_node_matcher :expect?, Expectations::ALL.send_pattern
        def_node_matcher :aggregate_failures_block?, <<-PATTERN
          (block (send _ :aggregate_failures ...) ...)
        PATTERN

        def on_block(node)
          return unless example?(node)

          return if example_with_aggregate_failures?(node)

          expectations_count = to_enum(:find_expectation, node).count

          return if expectations_count <= max_expectations

          self.max = expectations_count

          flag_example(node, expectation_count: expectations_count)
        end

        private

        def example_with_aggregate_failures?(example_node)
          node_with_aggregate_failures = find_aggregate_failures(example_node)
          return false unless node_with_aggregate_failures

          aggregate_failures?(node_with_aggregate_failures)
        end

        def find_aggregate_failures(example_node)
          example_node.send_node.each_ancestor(:block)
            .find { |block_node| aggregate_failures_present?(block_node) }
        end

        def aggregate_failures_present?(node)
          metadata(node)&.any?(&method(:with_aggregate_failures?))
        end

        def aggregate_failures?(example_or_group_node)
          metadata(example_or_group_node)&.any? do |metadata|
            with_aggregate_failures?(metadata) &&
              !disabled_aggregate_failures?(metadata)
          end
        end

        def metadata(example_or_group_node)
          RuboCop::RSpec::Example
            .new(example_or_group_node)
            .metadata
        end

        def find_expectation(node, &block)
          yield if expect?(node) || aggregate_failures_block?(node)

          # do not search inside of aggregate_failures block
          return if aggregate_failures_block?(node)

          node.each_child_node do |child|
            find_expectation(child, &block)
          end
        end

        def flag_example(node, expectation_count:)
          add_offense(
            node.send_node,
            message: format(
              MSG,
              total: expectation_count,
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
