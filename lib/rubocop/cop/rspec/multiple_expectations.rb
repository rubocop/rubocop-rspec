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
      #     it 'sets the users age'
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example configuration
      #
      #   # .rubocop.yml
      #   RSpec/MultipleExpectations:
      #     Max: 2
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

        MSG = 'Example has too many expectations [%{total}/%{max}]'.freeze

        def_node_search :expect, '(send _ :expect ...)'

        def on_block(node)
          return unless example?(node) && (expectations = expect(node))

          return if expectations.count <= max_expectations

          self.max = expectations.count

          flag_example(node, expectation_count: expectations.count)
        end

        private

        def flag_example(node, expectation_count:)
          method, = *node

          add_offense(
            method,
            :expression,
            format(MSG, total: expectation_count, max: max_expectations)
          )
        end

        def max_expectations
          Integer(cop_config.fetch('Max', 1))
        end
      end
    end
  end
end
