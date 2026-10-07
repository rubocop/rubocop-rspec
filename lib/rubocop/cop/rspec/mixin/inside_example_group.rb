# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps you identify whether a given node
      # is within an example group or not.
      module InsideExampleGroup
        private

        def inside_example_group?(node)
          return spec_group?(node) if example_group_root?(node)

          root = node.each_ancestor.find do |parent|
            example_group_root?(parent)
          end

          spec_group?(root)
        end

        def example_group_root?(node)
          node.parent.nil? || example_group_root_with_siblings?(node.parent)
        end

        def example_group_root_with_siblings?(node)
          node.begin_type? && node.parent.nil?
        end
      end
    end
  end
end
