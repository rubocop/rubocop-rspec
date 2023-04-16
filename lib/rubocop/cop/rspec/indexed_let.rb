# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not set up test data using indexes (e.g., `item_1`, `item_2`).
      #
      # It makes reading the test harder because it's not clear what exactly
      # is tested by this particular example.
      #
      # @example `Max: 1 (default)`
      #   # bad
      #   let(:item_1) { create(:item) }
      #   let(:item_2) { create(:item) }
      #
      #   let(:item1) { create(:item) }
      #   let(:item2) { create(:item) }
      #
      #   # good
      #
      #   let(:visible_item) { create(:item, visible: true) }
      #   let(:invisible_item) { create(:item, visible: false) }
      #
      # @example `Max: 2`
      #   # bad
      #   let(:item_1) { create(:item) }
      #   let(:item_2) { create(:item) }
      #   let(:item_3) { create(:item) }
      #
      #   # good
      #   let(:item_1) { create(:item) }
      #   let(:item_2) { create(:item) }
      #
      class IndexedLet < Base
        MSG = 'This `let` statement uses index in its name. Please give it ' \
              'a meaningful name.'

        # @!method let_name(node)
        def_node_matcher :let_name, <<~PATTERN
          {
            (block (send nil? #Helpers.all ({str sym} $_) ...) ...)
            (send nil? #Helpers.all ({str sym} $_) block_pass)
          }
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless spec_group?(node)

          children = node.body&.child_nodes
          return unless children

          filter_indexed_lets(children).each do |let_node|
            add_offense(let_node)
          end
        end

        private

        INDEX_REGEX = /_?\d+/.freeze

        def filter_indexed_lets(candidates)
          candidates
            .filter { |node| indexed_let?(node) }
            .group_by { |node| let_name(node).to_s.gsub(INDEX_REGEX, '') }
            .values
            .filter { |lets| lets.length > cop_config['Max'] }
            .flatten
        end

        def indexed_let?(node)
          let?(node) && INDEX_REGEX.match?(let_name(node))
        end
      end
    end
  end
end
