# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps check if a given node is within an example block.
      module InsideExample
        private

        def inside_example?(node)
          node.each_ancestor(:block).any? { |ancestor| example?(ancestor) }
        end
      end
    end
  end
end
