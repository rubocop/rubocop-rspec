# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Avoid duplicated metadata.
      #
      # @example
      #   # bad
      #   describe 'Something', :a, :a
      #
      #   # good
      #   describe 'Something', :a
      class DuplicatedMetadata < Base
        extend AutoCorrector

        include Metadata
        include RangeHelp

        MSG = 'Avoid duplicated metadata.'

        def on_metadata(symbols, _hash)
          symbols.each do |symbol|
            on_metadata_symbol(symbol)
          end
        end

        private

        def on_metadata_symbol(node)
          return unless duplicated?(node)

          add_offense(node) do |corrector|
            remove_with_preceding_comma(corrector, node)
          end
        end

        def duplicated?(node)
          node.left_siblings.any? do |sibling|
            sibling.eql?(node)
          end
        end
      end
    end
  end
end
