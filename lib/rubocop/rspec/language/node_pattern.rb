# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # Common node matchers used for matching against the rspec DSL
      module NodePattern
        extend RuboCop::NodePattern::Macros

        def_node_matcher :example_group?, ExampleGroups::ALL.block_pattern

        def_node_matcher :example_group_with_body?, <<-PATTERN
          (block #{ExampleGroups::ALL.send_pattern} args [!nil?])
        PATTERN

        def_node_matcher :example?, Examples::ALL.block_pattern
      end
    end
  end
end
