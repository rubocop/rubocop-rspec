# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check for repeated example group descriptions.
      #
      # @example
      #   # bad
      #   describe 'cool feature' do
      #     # example group
      #   end
      #
      #   describe 'cool feature' do
      #     # example group
      #   end
      #
      #   # bad
      #   context 'when case x' do
      #     # example group
      #   end
      #
      #   describe 'when case x' do
      #     # example group
      #   end
      #
      #   # good
      #   describe 'cool feature' do
      #     # example group
      #   end
      #
      #   describe 'another cool feature' do
      #     # example group
      #   end
      #
      #   # good
      #   context 'when case x' do
      #     # example group
      #   end
      #
      #   context 'when another case' do
      #     # example group
      #   end
      #
      class RepeatedExampleGroupDescription < Base
        include SkipOrPending
        include RepeatedItems

        MSG = 'Repeated %<group>s block description on line(s) %<loc>s'

        # @!method several_example_groups?(node)
        def_node_matcher :several_example_groups?, <<~PATTERN
          (begin <#example_group? #example_group? ...>)
        PATTERN

        # @!method doc_string_and_metadata(node)
        def_node_matcher :doc_string_and_metadata, <<~PATTERN
          (block (send _ _ $_ $...) ...)
        PATTERN

        # @!method empty_description?(node)
        def_node_matcher :empty_description?, '(block (send _ _) ...)'

        def on_begin(node)
          return unless several_example_groups?(node)

          repeated_group_descriptions(node).each do |group, repeats|
            add_offense(group, message: message(group, repeats))
          end
        end

        private

        def repeated_group_descriptions(node)
          items = node.children
            .select { |child| example_group?(child) }
            .reject { |child| skip_or_pending_inside_block?(child) }
            .reject { |child| empty_description?(child) }

          find_repeated_groups(
            items,
            key_proc: ->(group) { doc_string_and_metadata(group) }
          ).flat_map { |group| add_repeated_lines(group) }
        end

        def message(group, repeats)
          format(MSG, group: group.method_name, loc: repeats)
        end
      end
    end
  end
end
