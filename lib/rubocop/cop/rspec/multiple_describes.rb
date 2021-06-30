# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for multiple top-level example groups or nested example groups.
      #
      # This cop can be configured using the `EnforcedStyle` option.
      #
      # Using the `EnforcedStyle: nesting`, multiple example groups for the
      # same class or module should either be nested or separated into different
      # test files.
      #
      # Using the `EnforcedStyle: splitting`, nested example group for the
      # same class or module should be split into separate test files.
      #
      # @example `EnforcedStyle: nesting`
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
      # @example `EnforcedStyle: splitting`
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
      class MultipleDescribes < Base
        include TopLevelGroup
        include ConfigurableEnforcedStyle

        MSG = 'Do not use multiple top-level example groups - try to nest them.'
        MSG_SPLIT = 'Do not use nested describe - try to split them.'

        # @!method describe?(node)
        def_node_matcher :describe?, <<~PATTERN
          (send nil? :describe _ ...)
        PATTERN

        # @!method custom_matcher?(node)
        def_node_matcher :custom_matcher?, <<-PATTERN
          {
            (send nil? :matcher sym)
            (send (const (const nil? :RSpec) :Matchers) :define sym)
          }
        PATTERN

        # @!method negated_matcher?(node)
        def_node_matcher :negated_matcher?, <<-PATTERN
          (send (const (const nil? :RSpec) :Matchers) :define_negated_matcher sym sym)
        PATTERN

        # @!method expectation?(node)
        def_node_matcher :expectation?, <<~PATTERN
          (send (send nil? #Expectations.all ...) {:to :not_to} _)
        PATTERN

        def on_top_level_group(node)
          return unless style == :nesting

          top_level_example_groups =
            top_level_groups.select(&method(:example_group?))

          return if top_level_example_groups.one?
          return unless top_level_example_groups.first.equal?(node)

          add_offense(node.send_node)
        end

        def on_send(node)
          return unless style == :splitting
          return unless describe?(node)

          block_node = node.parent
          return if root_node?(block_node)

          return if use_common_code?(node)

          return if check_all_previous_example_groups?(block_node)

          add_offense(node, message: MSG_SPLIT)
        end

        private

        def root_node?(node)
          node.parent.nil? || root_with_siblings?(node.parent)
        end

        def root_with_siblings?(node)
          node.begin_type? && node.parent.nil?
        end

        def use_common_code?(node)
          use_shared_group?(node) || use_custom_matcher?(node) ||
            example_group_in_shared_group(node)
        end

        def use_shared_group?(node)
          shared_group_method_names = shared_group_method_names(node)

          node.parent.each_descendant(:send).any? do |send_node|
            include?(send_node) &&
              shared_group_method_names.include?(send_node.first_argument)
          end
        end

        def shared_group_method_names(node)
          node.each_ancestor(:block).map do |block_node|
            parent = block_node.parent
            next if parent.nil?

            parent.child_nodes.each_with_object([]) do |child_node, result|
              if shared_group?(child_node)
                shared_group = child_node.child_nodes.first
                result << shared_group.first_argument
              end
            end
          end.flatten
        end

        def use_custom_matcher?(node)
          custom_matcher_method_names =
            matcher_method_names_in_ancestor_nodes(node)

          block_node = node.each_ancestor(:block).first
          block_node.parent.each_descendant(:send).any? do |send_node|
            next unless expectation?(send_node)

            send_node.each_descendant(:send).any? do |child_send_node|
              custom_matcher_method_names.include?(child_send_node.method_name)
            end
          end
        end

        def matcher_method_names_in_ancestor_nodes(node)
          node.each_ancestor(:block).map do |block_node|
            parent = block_node.parent
            next if parent.nil?

            matcher_method_names(parent)
          end.flatten
        end

        def matcher_method_names(node)
          node.child_nodes.each_with_object([]) do |child_node, result|
            send_node = child_node.each_descendant(:send).first
            if custom_matcher?(send_node)
              result << send_node.first_argument.value
            elsif negated_matcher?(child_node)
              result << child_node.arguments.map(&:value)
            end
          end
        end

        def example_group_in_shared_group(node)
          node.each_ancestor(:block).any? do |block_node|
            shared_group?(block_node)
          end
        end

        def check_all_previous_example_groups?(block_node)
          block_node.parent.child_nodes.any? do |child_node|
            break if child_node.equal?(block_node)

            child_node.child_nodes.any? { |child| describe?(child) }
          end
        end
      end
    end
  end
end
