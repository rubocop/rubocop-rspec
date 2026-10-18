# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for let scattered across the example group.
      #
      # Group lets together
      #
      # @example
      #   # bad
      #   describe Foo do
      #     let(:foo) { 1 }
      #     subject { Foo }
      #     let(:bar) { 2 }
      #     before { prepare }
      #     let!(:baz) { 3 }
      #   end
      #
      #   # good
      #   describe Foo do
      #     let(:foo) { 1 }
      #     let(:bar) { 2 }
      #     let!(:baz) { 3 }
      #     subject { Foo }
      #     before { prepare }
      #   end
      #
      #   # good - a Sorbet `sig` belongs to the `let` it precedes
      #   describe Foo do
      #     sig { returns(Integer) }
      #     let(:foo) { 1 }
      #     sig { returns(Integer) }
      #     let(:bar) { 2 }
      #   end
      #
      class ScatteredLet < Base
        extend AutoCorrector

        MSG = 'Group all let/let! blocks in the example group together.'

        # @!method sig_block?(node)
        def_node_matcher :sig_block?, '(block (send nil? :sig ...) _ _)'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless example_group_with_body?(node)

          check_let_declarations(node.body)
        end

        private

        def check_let_declarations(body)
          nodes = children_without_let_sigs(body)
          lets = nodes.select { |node| let?(node) }
          return if lets.empty?

          expected = nodes.drop(nodes.index(lets.first))
          reference_let = lets.first

          lets.zip(expected).each do |node, expected_node|
            if node.equal?(expected_node)
              reference_let = node
            else
              register_offense(node, reference_let)
            end
          end
        end

        def register_offense(node, reference_let)
          add_offense(node) do |corrector|
            RuboCop::RSpec::Corrector::MoveNode.new(
              node, corrector, processed_source
            ).move_after(reference_let)
          end
        end

        def children_without_let_sigs(body)
          body.each_child_node.reject { |node| sig_for_let?(node) }
        end

        def sig_for_let?(node)
          return false unless sig_block?(node)

          next_node = node.right_sibling
          next_node.is_a?(RuboCop::AST::Node) && let?(next_node)
        end
      end
    end
  end
end
