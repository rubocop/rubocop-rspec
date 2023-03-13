# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks where `contain_exactly` is used.
      #
      # This cop checks for the following:
      # - Prefer `match_array` when matching array values.
      # - Prefer `be_empty` when using `contain_exactly` with no arguments.
      #
      # @example
      #   # bad
      #   it { is_expected.to contain_exactly(*array1, *array2) }
      #
      #   # good
      #   it { is_expected.to match_array(array1 + array2) }
      #
      #   # good
      #   it { is_expected.to contain_exactly(content, *array) }
      #
      #   # bad
      #   it { is_expected.to contain_exactly }
      #   it { is_expected.to contain_exactly() }
      #
      #   # good
      #   it { is_expected.to be_empty }
      #   it { is_expected.to be_empty }
      #
      class ContainExactly < Base
        extend AutoCorrector

        MSG = 'Prefer `match_array` when matching array values.'
        MSG_EMPTY_COLLECTION =
          'Prefer `be_empty` when matching an empty collection.'
        RESTRICT_ON_SEND = %i[contain_exactly].freeze

        def on_send(node)
          if node.arguments.empty?
            check_empty_collection(node)
          else
            check_populated_collection(node)
          end
        end

        private

        def check_empty_collection(node)
          add_offense(node, message: MSG_EMPTY_COLLECTION) do |corrector|
            corrector.replace(node.source_range, 'be_empty')
          end
        end

        def check_populated_collection(node)
          return unless node.each_child_node.all?(&:splat_type?)

          add_offense(node) do |corrector|
            autocorrect_for_populated_array(node, corrector)
          end
        end

        def autocorrect_for_populated_array(node, corrector)
          arrays = node.arguments.map do |splat_node|
            splat_node.children.first
          end
          corrector.replace(
            node.source_range,
            "match_array(#{arrays.map(&:source).join(' + ')})"
          )
        end
      end
    end
  end
end
