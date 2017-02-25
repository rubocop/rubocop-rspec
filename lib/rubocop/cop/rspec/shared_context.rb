# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for proper shared_context and shared_examples usage.
      #
      # If there are no examples defined, use shared_context.
      # If there is no setup defined, use shared_examples.
      #
      # @example
      #   # bad
      #   RSpec.shared_context 'only examples here' do
      #     it 'does x' do
      #     end
      #
      #     it 'does 'y' do
      #     end
      #   end
      #
      #   # good
      #   RSpec.shared_examples 'only examples here' do
      #     it 'does x' do
      #     end
      #
      #     it 'does 'y' do
      #     end
      #   end
      #
      # @example
      #   # bad
      #   RSpec.shared_examples 'only setup here' do
      #     subject(:foo) { :bar }
      #
      #     let(:baz) { :bazz }
      #
      #     before do
      #       something
      #     end
      #   end
      #
      #   # good
      #   RSpec.shared_context 'only setup here' do
      #     subject(:foo) { :bar }
      #
      #     let(:baz) { :bazz }
      #
      #     before do
      #       something
      #     end
      #   end
      #
      class SharedContext < Cop
        MESSAGE_EXAMPLES = "Use `shared_examples` when you don't define context"
          .freeze
        MESSAGE_CONTEXT = "Use `shared_context` when you don't define examples"
          .freeze

        EXAMPLES = (Examples::ALL + Includes::EXAMPLES)
        def_node_search :examples?, EXAMPLES.send_pattern

        CONTEXT = (Hooks::ALL + Helpers::ALL + Includes::CONTEXT + Subject::ALL)
        def_node_search :context?, CONTEXT.send_pattern

        def on_block(node)
          context_with_only_examples(node) do
            add_offense(node.children.first, :expression, MESSAGE_EXAMPLES)
          end

          examples_with_only_context(node) do
            add_offense(node.children.first, :expression, MESSAGE_CONTEXT)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            context_with_only_examples(node.parent) do
              corrector.replace(node.loc.selector, 'shared_examples')
            end
            examples_with_only_context(node.parent) do
              corrector.replace(node.loc.selector, 'shared_context')
            end
          end
        end

        private

        def context_with_only_examples(node)
          _receiver, method, _args = *node.children.first
          return unless SharedGroups::CONTEXT.include?(method)

          yield if examples?(node) && !context?(node)
        end

        def examples_with_only_context(node)
          _receiver, method, _args = *node.children.first
          return unless SharedGroups::EXAMPLES.include?(method)

          yield if context?(node) && !examples?(node)
        end
      end
    end
  end
end
