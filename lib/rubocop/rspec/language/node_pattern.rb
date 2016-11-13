# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # Common node matchers used for matching against the rspec DSL
      module NodePattern
        extend RuboCop::NodePattern::Macros

        def_node_matcher :example_group?, <<-PATTERN
          (block (send _ #{ExampleGroups::ALL.node_pattern_union} ...) ...)
        PATTERN
      end
    end
  end
end
