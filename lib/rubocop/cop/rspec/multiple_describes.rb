# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for multiple top-level example groups or nested example groups.
      #
      # In the default configuration, multiple descriptions for the same class
      # or module should either be nested or separated into different test
      # files.
      #
      # This cop can be configured with the option `Splitting` which will
      # check that nested describe for the same class or module must be either
      # nested or split into separate test files.
      #
      # @example
      #   # bad
      #   describe MyClass, '.do_something' do
      #   end
      #   describe MyClass, '.do_something_else' do
      #   end
      #
      #   # good
      #   describe MyClass do
      #     describe '.do_something' do
      #     end
      #     describe '.do_something_else' do
      #     end
      #   end
      #
      # @example with Splitting configuration
      #
      #   # rubocop.yml
      #   # RSpec/InstanceVariable:
      #   #   AssignmentOnly: false
      #
      #   # bad
      #   describe MyClass do
      #     describe '.do_something' do
      #     end
      #     describe '.do_something_else' do
      #     end
      #   end
      #
      #   # good
      #   describe MyClass, '.do_something' do
      #   end
      #   describe MyClass, '.do_something_else' do
      #   end
      #
      #   # allowed
      #   RSpec.describe MyClass do
      #     shared_examples 'behaves' do;end
      #
      #     describe '#do_something' do
      #       subject { my_class_instance.foo }
      #     end
      #   end
      #
      #   # allowed
      #   RSpec.describe MyClass do
      #     RSpec::Matchers.define :be_a_multiple_of do |expected|
      #       match do |actual|
      #         actual % expected == 0
      #       end
      #     end
      #
      #     describe '#do_something' do
      #       subject { my_class_instance.foo }
      #     end
      #   end
      #
      class MultipleDescribes < Base
        include TopLevelGroup

        MSG = 'Do not use multiple top-level example groups - try to nest them.'
        MSG_SPLIT = 'Do not use nested describe - try to split them.'

        # @!method describe?(node)
        def_node_matcher :describe?, <<~PATTERN
          (send nil? :describe _ ...)
        PATTERN

        # @!method custom_matcher?(node)
        def_node_matcher :custom_matcher?, <<-PATTERN
          (block {
            (send nil? :matcher sym)
            (send (const (const nil? :RSpec) :Matchers) :define sym)
          } ...)
        PATTERN

        # @!method shared_example?(node)
        def_node_matcher :shared_example?, block_pattern('#SharedGroups.all')

        def on_top_level_group(node)
          return if splitting?

          top_level_example_groups =
            top_level_groups.select(&method(:example_group?))

          return if top_level_example_groups.one?
          return unless top_level_example_groups.first.equal?(node)

          add_offense(node.send_node)
        end

        def on_send(node)
          return unless splitting?

          return unless describe?(node)

          return if includes_common_codes?(node)

          block_node = node.parent
          return if root_node?(block_node)
          return if includes_describe_in_previous_node?(block_node)

          add_offense(node, message: MSG_SPLIT)
        end

        private

        def splitting?
          cop_config['Splitting']
        end

        def includes_describe_in_previous_node?(block_node)
          previous_block_node = previous_sibling(block_node)
          return false if previous_block_node.nil?

          if previous_block_node.child_nodes.any? { |child| describe?(child) }
            return true
          end

          includes_describe_in_previous_node?(previous_block_node)
        end

        def includes_common_codes?(node)
          root = root_node_for_current_node(node)

          root.each_descendant(:block).any? do |child|
            shared_example?(child) || custom_matcher?(child)
          end
        end

        def previous_sibling(block_node)
          return nil if (block_node.sibling_index - 1).negative?

          block_node.parent.child_nodes[block_node.sibling_index - 1]
        end

        def root_node_for_current_node(node)
          node.ancestors.find { |parent| root_node?(parent) }
        end

        def root_node?(node)
          node.parent.nil? || root_with_siblings?(node.parent)
        end

        def root_with_siblings?(node)
          node.begin_type? && node.parent.nil?
        end
      end
    end
  end
end
