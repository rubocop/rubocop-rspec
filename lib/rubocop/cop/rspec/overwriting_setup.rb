# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is a let/subject that overwrites an existing one.
      #
      # @example
      #   # bad
      #     let(:foo) { bar }
      #     let(:foo) { baz }
      #
      #     subject(:foo) { bar }
      #     let(:foo) { baz }
      #
      #     let(:foo) { bar }
      #     let!(:foo) { baz }
      #
      #   # good
      #     subject(:test) { something }
      #     let(:foo) { bar }
      #     let(:baz) { baz }
      #     let!(:other) { other }
      class OverwritingSetup < Cop
        MSG = '`%<name>s` is already defined.'.freeze

        def_node_matcher :setup?, <<-PATTERN
          (block (send nil? {:let :let! :subject} (sym $_)) ...)
        PATTERN

        def on_block(node)
          return unless example_group_with_body?(node)

          _describe, _args, body = *node

          find_duplicates(body) do |duplicate, name|
            add_offense(
              duplicate,
              location: :expression,
              message: format(MSG, name: name)
            )
          end
        end

        private

        def find_duplicates(node)
          setup_expressions = Set.new
          node.each_child_node do |child|
            setup?(child) do |name|
              yield child, name unless setup_expressions.add?(name)
            end
          end
        end
      end
    end
  end
end
