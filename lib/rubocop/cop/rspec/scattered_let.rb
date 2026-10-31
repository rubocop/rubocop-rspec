# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for let scattered across the example group.
      #
      # Group lets together
      #
      # Autocorrection does not move a `let!` above a hook, because `let!`
      # runs as a `before` hook and moving it would change the order in which
      # the setup runs.
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
      class ScatteredLet < Base
        extend AutoCorrector

        MSG = 'Group all let/let! blocks in the example group together.'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless example_group_with_body?(node)

          check_let_declarations(node.body)
        end

        private

        def check_let_declarations(body)
          lets = body.each_child_node.select { |node| let?(node) }
          return if lets.empty?

          first_let = lets.first
          reference_let = first_let

          lets.each_with_index do |node, idx|
            if node.sibling_index == first_let.sibling_index + idx
              reference_let = node
              next
            end

            add_offense(node) do |corrector|
              autocorrect(corrector, node, reference_let)
            end
          end
        end

        def autocorrect(corrector, node, reference_let)
          return if let_bang_across_hook?(node, reference_let)

          RuboCop::RSpec::Corrector::MoveNode.new(
            node, corrector, processed_source
          ).move_after(reference_let)
        end

        def let_bang_across_hook?(node, reference_let)
          return false unless node.method?(:let!)

          node.left_siblings[(reference_let.sibling_index + 1)..]
            .any? { |sibling| hook?(sibling) }
        end
      end
    end
  end
end
