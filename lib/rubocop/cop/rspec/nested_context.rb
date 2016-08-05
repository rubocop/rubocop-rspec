# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for nested contexts
      #
      # @example
      #   # bad
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
      #       context 'when user is an admin' do
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
      class NestedContext < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG = 'Maximum context nesting exceeded'.freeze

        def_node_search :find_contexts, <<-PATTERN
          (block (send nil :context ...) (args) ...)
        PATTERN

        def on_block(node)
          describe, = described_constant(node)
          return unless describe

          find_nested_contexts(node) do |context|
            add_offense(context.children.first, :expression)
          end
        end

        private

        def find_nested_contexts(node, nesting: nil, &block)
          find_contexts(node) do |nested_context|
            yield(nested_context) if nesting

            nested_context.each_child_node do |child|
              find_nested_contexts(child, nesting: true, &block)
            end
          end
        end
      end
    end
  end
end
