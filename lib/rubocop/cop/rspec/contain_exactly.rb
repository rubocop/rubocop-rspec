# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks where `contain_exactly` is used.
      #
      # This cop checks for the following:
      #
      # - Prefer `match_array` when matching array values.
      # - Prefer `be_empty` when using `contain_exactly` with no arguments.
      #
      # @example
      #   # bad
      #   it { is_expected.to contain_exactly(*array) }
      #
      #   # good
      #   it { is_expected.to match_array(array) }
      #
      #   # good
      #   it { is_expected.to contain_exactly(*array1, *array2) }
      #
      #   # good
      #   it { is_expected.to contain_exactly(content, *array) }
      #
      class ContainExactly < Base
        extend AutoCorrector

        MSG = 'Prefer `match_array` when matching array values.'
        RESTRICT_ON_SEND = %i[contain_exactly].freeze

        def on_send(node)
          return unless node.arguments.one? && node.first_argument.splat_type?

          add_offense(node) do |corrector|
            array = node.first_argument.children.first
            corrector.replace(node, "match_array(#{array.source})")
          end
        end
      end
    end
  end
end
