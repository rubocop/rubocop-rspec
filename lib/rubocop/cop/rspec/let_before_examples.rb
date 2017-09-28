# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for `let` definitions that come after an example.
      #
      # @example
      #   # Bad
      #   let(:foo) { bar }
      #
      #   it 'checks what foo does' do
      #     expect(foo).to be
      #   end
      #
      #   let(:some) { other }
      #
      #   it 'checks what some does' do
      #     expect(some).to be
      #   end
      #
      #   # Good
      #   let(:foo) { bar }
      #   let(:some) { other }
      #
      #   it 'checks what foo does' do
      #     expect(foo).to be
      #   end
      #
      #   it 'checks what some does' do
      #     expect(some).to be
      #   end
      class LetBeforeExamples < Cop
        MSG = 'Move `let` before the examples in the group.'.freeze

        def_node_matcher :let?, '(block (send nil {:let :let!} ...) ...)'
        def_node_matcher :example_or_group?, <<-PATTERN
          {
            #{(Examples::ALL + ExampleGroups::ALL).block_pattern}
            #{Includes::EXAMPLES.send_pattern}
          }
        PATTERN

        def on_block(node)
          return unless example_group_with_body?(node)

          check_let_declarations(node.body) if multiline_block?(node.body)
        end

        private

        def multiline_block?(block)
          block.begin_type?
        end

        def check_let_declarations(node)
          example_found = false

          node.each_child_node do |child|
            if let?(child)
              add_offense(child, :expression) if example_found
            elsif example_or_group?(child)
              example_found = true
            end
          end
        end
      end
    end
  end
end
