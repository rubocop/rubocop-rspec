# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Prefer `contain_exactly` when matching an array literal.
      #
      # @example
      #   # bad
      #   it { is_expected.to match_array([content1, content2]) }
      #
      #   # good
      #   it { is_expected.to contain_exactly(content1, content2) }
      #
      #   # good
      #   it { is_expected.to match_array([content] + array) }
      #
      #   # good
      #   it { is_expected.to match_array(%w(tremble in fear foolish mortals)) }
      class MatchArray < Base
        extend AutoCorrector

        MSG = 'Prefer `contain_exactly` when matching an array literal.'
        RESTRICT_ON_SEND = %i[match_array].freeze

        # @!method match_array_with_empty_array?(node)
        def_node_matcher :match_array_with_empty_array?, <<~PATTERN
          (send nil? :match_array (array))
        PATTERN

        def on_send(node)
          return if match_array_with_empty_array?(node)
          return unless offensive_argument?(node)

          add_offense(node) do |corrector|
            array_contents = node.arguments.flat_map(&:to_a)
            corrector.replace(
              node.source_range,
              "contain_exactly(#{array_contents.map(&:source).join(', ')})"
            )
          end
        end

        private

        def offensive_argument?(node)
          return unless (first_argument = node.first_argument)

          first_argument.array_type? && !first_argument.percent_literal?
        end
      end
    end
  end
end
