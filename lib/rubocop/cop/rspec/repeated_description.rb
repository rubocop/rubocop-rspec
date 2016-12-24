module RuboCop
  module Cop
    module RSpec
      # Check for repeated description strings in example groups.
      #
      # @example
      #
      #     # bad
      #     RSpec.describe User do
      #       it 'is valid' do
      #         # ...
      #       end
      #
      #       it 'is valid' do
      #         # ...
      #       end
      #     end
      #
      #     # good
      #     RSpec.describe User do
      #       it 'is valid when first and last name are present' do
      #         # ...
      #       end
      #
      #       it 'is valid when last name only is present' do
      #         # ...
      #       end
      #     end
      #
      class RepeatedDescription < Cop
        def_node_matcher :example, <<-PATTERN
          (block $(send _ #{Examples::ALL.node_pattern_union} str ...) ...)
        PATTERN

        # @!method scope_change?(node)
        #
        #   Detect if the node is an example group or shared example
        #
        #   Selectors which indicate that we should stop searching
        #
        def_node_matcher :scope_change?,
                         (ExampleGroups::ALL + SharedGroups::ALL).block_pattern

        MSG = "Don't repeat descriptions within an example group.".freeze

        def on_block(node)
          return unless example_group?(node)

          repeated_descriptions(node).each do |repeated_hook|
            add_offense(repeated_hook, :expression)
          end
        end

        private

        # Select examples in the current scope with repeated description strings
        def repeated_descriptions(node)
          examples_in_scope(node)    # Select examples in example group
            .group_by(&:method_args) # Group examples by description string
            .values                  # Reduce to array of grouped examples
            .reject(&:one?)          # Reject groups with only one example
            .flatten                 # Flatten down to array of offending nodes
        end

        def examples_in_scope(node, &block)
          return to_enum(__method__, node) unless block_given?

          node.each_child_node { |child| find_examples(child, &block) }
        end

        # Recursively search for examples within the current scope
        #
        # Searches node for examples and halts when a scope change is detected
        #
        # @param node [RuboCop::Node] node to recursively search for examples
        #
        # @yield [RuboCop::Node] discovered example nodes
        def find_examples(node, &block)
          return if scope_change?(node)

          example(node, &block)
          examples_in_scope(node, &block)
        end
      end
    end
  end
end
