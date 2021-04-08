# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that the multiple `describe` is split or combined.
      #
      # This cop can be configured using the `Splitting` and `Combining`
      # options.
      #
      # @example `Splitting: describe_top_level_group`
      #   # bad
      #   RSpec.describe MyClass do
      #     describe '#foo' do
      #       subject { my_class_instance.foo }
      #     end
      #
      #     describe '#bar' do
      #       subject { my_class_instance.bar }
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe MyClass do
      #     describe '#foo' do
      #       subject { my_class_instance.foo }
      #     end
      #   end
      #
      #   RSpec.describe MyClass do
      #     describe '#bar' do
      #       subject { my_class_instance.bar }
      #     end
      #   end
      #
      # @example `Combining: describe_top_level_group`
      #   # bad
      #   RSpec.describe MyClass do
      #     describe '#foo' do
      #       subject { my_class_instance.foo }
      #     end
      #   end
      #
      #   RSpec.describe MyClass do
      #     describe '#bar' do
      #       subject { my_class_instance.bar }
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe MyClass do
      #     describe '#foo' do
      #       subject { my_class_instance.foo }
      #     end
      #
      #     describe '#bar' do
      #       subject { my_class_instance.bar }
      #     end
      #   end
      #
      class DescribeTopLevelGroup < Base
        include TopLevelGroup

        MSG_MULTIPLE = 'Combine multiple describe.'
        MSG_SPLIT = 'Split multiple describe.'

        # @!method rspec_method_with_class?(node)
        def_node_matcher :rspec_method_with_class?, <<~PATTERN
          (send #rspec? #ExampleGroups.all const ...)
        PATTERN

        # @!method rspec_method?(node)
        def_node_matcher :rspec_method?, <<~PATTERN
          #{send_pattern('#ExampleGroups.all')}
        PATTERN

        # @!method rspec_block?(node)
        def_node_matcher :rspec_block?, <<~PATTERN
          (block
            #{send_pattern('#ExampleGroups.all')}...
          )
        PATTERN

        # @!method describe?(node)
        def_node_matcher :describe?, <<~PATTERN
          (send nil? :describe _ ...)
        PATTERN

        def on_send(node)
          return unless combining?

          return unless rspec_method_with_class?(node)

          block_node = node.parent
          return unless root_node?(block_node)
          return if contains_rspec_method_before_node?(block_node)
          return unless contains_rspec_method_after_node?(block_node)

          add_offense(node, message: MSG_MULTIPLE)
        end

        def on_top_level_group(node)
          return unless splitting?

          return unless rspec_block?(node)

          first_describe = find_first_describe(node)
          return unless first_describe

          add_offense(first_describe, message: MSG_SPLIT)
        end

        private

        def splitting?
          cop_config['Splitting']
        end

        def combining?
          cop_config['Combining']
        end

        def contains_rspec_method_before_node?(node)
          before_node = before_sibling(node)
          return false if before_node.nil?

          before_node.child_nodes.each do |child|
            return true if rspec_method?(child)
          end

          contains_rspec_method_before_node?(before_node)
        end

        def contains_rspec_method_after_node?(node)
          next_node = next_sibling(node)
          return false if next_node.nil?

          next_node.child_nodes.each do |child|
            return true if rspec_method?(child)
          end

          contains_rspec_method_after_node?(next_node)
        end

        def contains_describe_after_node?(node)
          next_node = next_sibling(node)
          return false if next_node.nil?

          next_node.child_nodes.each do |child|
            return true if describe?(child)
          end

          contains_describe_after_node?(next_node)
        end

        def find_first_describe(node)
          detected_begin = node.child_nodes.find(&:begin_type?)
          return nil unless detected_begin

          detected_begin.child_nodes.each do |child|
            first_describe_node = child.child_nodes.find do |grand_child|
              describe?(grand_child)
            end

            next if first_describe_node.nil?

            return first_describe_node if contains_describe_after_node?(child)
          end

          nil
        end

        def root_node?(node)
          node.parent.nil? || root_with_siblings?(node.parent)
        end

        def root_with_siblings?(node)
          node.begin_type? && node.parent.nil?
        end

        def next_sibling(node)
          return nil if node.sibling_index.nil?

          node.parent.child_nodes[node.sibling_index + 1]
        end

        def before_sibling(node)
          return nil if node.parent.nil? || (node.sibling_index - 1).negative?

          node.parent.child_nodes[node.sibling_index - 1]
        end
      end
    end
  end
end
