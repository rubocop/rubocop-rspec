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
      #     subject { Foo }
      #     before { prepare }
      #     let(:foo) { 1 }
      #     let(:bar) { 2 }
      #     let!(:baz) { 3 }
      #   end
      #
      class ScatteredLet < Cop
        MSG = 'Group all let/let! blocks in the example group together.'.freeze

        def_node_matcher :let?, '(block (send nil {:let :let!} ...) ...)'

        def on_block(node)
          return unless example_group_with_body?(node)

          _describe, _args, body = *node

          check_let_declarations(body)
        end

        def check_let_declarations(node)
          let_found = false
          mix_found = false

          node.each_child_node do |child|
            if let?(child)
              add_offense(child, :expression) if mix_found
              let_found = true
            elsif let_found
              mix_found = true
            end
          end
        end
      end
    end
  end
end
