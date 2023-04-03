# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Prefer to travel in `before` rather than `around`.
        #
        # @safety
        #   This cop is unsafe because the automatic `travel_back` is only run
        #   on test cases that are considered as Rails related.
        #
        #   And also, this cop's autocorrection is unsafe because the order of
        #   execution will change if other steps exist before traveling in
        #   `around`.
        #
        # @example
        #   # bad
        #   around do |example|
        #     freeze_time do
        #       example.run
        #     end
        #   end
        #
        #   # good
        #   before { freeze_time }
        class TravelAround < Base
          extend AutoCorrector

          MSG = 'Prefer to travel in `before` rather than `around`.'

          TRAVEL_METHOD_NAMES = %i[
            freeze_time
            travel
            travel_to
          ].to_set.freeze

          # @!method extract_run_in_travel(node)
          def_node_matcher :extract_run_in_travel, <<~PATTERN
            (block
              $(send nil? TRAVEL_METHOD_NAMES ...)
              (args ...)
              (send _ :run)
            )
          PATTERN

          # @!method match_around_each?(node)
          def_node_matcher :match_around_each?, <<~PATTERN
            (block
              (send _ :around (sym :each)?)
              ...
            )
          PATTERN

          def on_block(node)
            run_node = extract_run_in_travel(node)
            return unless run_node

            around_node = extract_surrounding_around_block(run_node)
            return unless around_node

            add_offense(node) do |corrector|
              autocorrect(corrector, node, run_node, around_node)
            end
          end
          alias on_numblock on_block

          private

          def autocorrect(corrector, node, run_node, around_node)
            corrector.replace(node, node.body.source)
            if (before_node = extract_before_block(around_node))
              corrector.insert_after(before_node.body, ";#{run_node.source}")
            else
              corrector.insert_before(around_node,
                                      "before { #{run_node.source} }\n\n")
            end
          end

          # @param node [RuboCop::AST::BlockNode]
          # @return [RuboCop::AST::BlockNode, nil]
          def extract_surrounding_around_block(node)
            node.each_ancestor(:block).find do |ancestor|
              match_around_each?(ancestor)
            end
          end

          # @param node [RuboCop::AST::BlockNode]
          # @return [RuboCop::AST::BlockNode, nil]
          def extract_before_block(node)
            return unless node.parent?

            node.parent.each_child_node(:block).find do |child|
              child.method?(:before)
            end
          end
        end
      end
    end
  end
end
