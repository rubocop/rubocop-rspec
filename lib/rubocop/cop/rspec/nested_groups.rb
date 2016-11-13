# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for nested example groups.
      #
      # This cop is configurable using the `MaxNesting` option
      #
      # @example
      #   # bad
      #   context 'when using some feature' do
      #     let(:some)    { :various }
      #     let(:feature) { :setup   }
      #
      #     context 'when user is signed in' do  # flagged by rubocop
      #       let(:user) do
      #         UserCreate.call(user_attributes)
      #       end
      #
      #       let(:user_attributes) do
      #         {
      #           name: 'John',
      #           age:  22
      #           role: role
      #         }
      #       end
      #
      #       context 'when user is an admin' do # flagged by rubocop
      #         let(:role) { 'admin' }
      #
      #         it 'blah blah'
      #         it 'yada yada'
      #       end
      #     end
      #   end
      #
      #   # better
      #   context 'using some feature as an admin' do
      #     let(:some)    { :various }
      #     let(:feature) { :setup   }
      #
      #     let(:user) do
      #       UserCreate.call(
      #         name: 'John',
      #         age:  22
      #         role: 'admin'
      #       )
      #     end
      #
      #     it 'blah blah'
      #     it 'yada yada'
      #   end
      #
      # @example configuration
      #
      #   # .rubocop.yml
      #   RSpec/NestedGroups:
      #     MaxNesting: 2
      #
      #   context 'when using some feature' do
      #     let(:some)    { :various }
      #     let(:feature) { :setup   }
      #
      #     context 'when user is signed in' do
      #       let(:user) do
      #         UserCreate.call(user_attributes)
      #       end
      #
      #       let(:user_attributes) do
      #         {
      #           name: 'John',
      #           age:  22
      #           role: role
      #         }
      #       end
      #
      #       context 'when user is an admin' do # flagged by rubocop
      #         let(:role) { 'admin' }
      #
      #         it 'blah blah'
      #         it 'yada yada'
      #       end
      #     end
      #   end
      #
      class NestedGroups < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG = 'Maximum example group nesting exceeded'.freeze

        def_node_search :find_contexts, <<-PATTERN
          (block (send nil #{ExampleGroups::ALL.node_pattern_union} ...) (args) ...)
        PATTERN

        def on_block(node)
          describe, = described_constant(node)
          return unless describe

          find_nested_contexts(node) do |context|
            add_offense(context.children.first, :expression)
          end
        end

        private

        def find_nested_contexts(node, nesting: 1, &block)
          find_contexts(node) do |nested_context|
            yield(nested_context) if nesting > max_nesting

            nested_context.each_child_node do |child|
              find_nested_contexts(child, nesting: nesting + 1, &block)
            end
          end
        end

        def max_nesting
          Integer(cop_config.fetch('MaxNesting', 2))
        end
      end
    end
  end
end
