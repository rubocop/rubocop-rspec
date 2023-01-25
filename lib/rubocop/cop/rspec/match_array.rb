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

        def on_send(node)
          return unless node.first_argument.array_type?
          return if node.first_argument.percent_literal?

          add_offense(node) do |corrector|
            array_contents = node.arguments.flat_map(&:to_a)
            corrector.replace(
              node.source_range,
              "contain_exactly(#{array_contents.map(&:source).join(', ')})"
            )
          end
        end
      end
    end
  end
end
