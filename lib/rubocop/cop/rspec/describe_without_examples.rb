# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks `describe` and `context` without `it`.
      #
      # @example
      #   # bad
      #   describe do
      #   end
      #
      #   # bad
      #   describe do
      #     before
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   describe do
      #     it do
      #       expect(foo).to eq(something)
      #     end
      #   end
      #
      #   # good
      #   describe do
      #     before
      #       do_something
      #     end
      #
      #     it do
      #       expect(foo).to eq(something)
      #     end
      #   end
      class DescribeWithoutExamples < Cop
        MSG = 'Do not use `%<method_name>s` without examples.'.freeze
        GROUPS = ExampleGroups::ALL.block_pattern
        EXAMPLES = Examples::ALL.block_pattern
        INCLUDES = Includes::EXAMPLES.send_pattern

        def_node_matcher :example_group?, GROUPS
        def_node_search :has_examples?, <<-PATTERN
          {
            #{EXAMPLES}
            #{INCLUDES}
          }
        PATTERN

        def on_block(node)
          example_group?(node) do
            on_example_group(node)
          end
        end

        private

        def on_example_group(node)
          add_offense(node) unless has_examples?(node)
        end

        def message(node)
          format(MSG, method_name: node.method_name)
        end
      end
    end
  end
end
