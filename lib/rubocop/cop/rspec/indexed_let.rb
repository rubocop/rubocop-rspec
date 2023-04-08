# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not set up test data using indexes (e.g., `item_1`, `item_2`).
      #
      # It makers reading the test harder because it's not clear what exactly
      # is tested by this particular example.
      #
      # This cop is configurable using the `MaxRepeats` option.
      #
      # @example
      #   # bad
      #   let(:item_1) { create(:item) }
      #   let(:item_2) { create(:item) }
      #
      #   let("item_1") { create(:item) }
      #   let("item_2") { create(:item) }
      #
      #   let(:item1) { create(:item) }
      #   let(:item2) { create(:item) }
      #
      #   let(:item_1) { create(:item, visible: true) }
      #   let(:item_2) { create(:item, visible: false) }
      #
      #   # good
      #   let(:items) { create_list(:item, 2) }
      #
      #   let(:visible_item) { create(:item, visible: true) }
      #   let(:invisible_item) { create(:item, visible: false) }
      #
      class IndexedLet < Base
        MSG = 'This `let` statement uses index in its name. Please give it ' \
              'a meaningful names, use create_list or move creation ' \
              'to the `before` block.'

        # @!method let_name(node)
        def_node_matcher :let_name, <<~PATTERN
          {
            (block (send nil? #Helpers.all ({str sym} $_) ...) ...)
            (send nil? #Helpers.all ({str sym} $_) block_pass)
          }
        PATTERN

        def on_block(node)
          return unless spec_group?(node)

          children = node.body&.child_nodes
          return unless children

          filter_indexed_lets(children).each do |let_node|
            add_offense(let_node)
          end
        end

        alias on_numblock on_block

        private

        INDEX_REGEX = /_?\d+/.freeze

        def filter_indexed_lets(candidates)
          candidates
            .filter { |candidate| let?(candidate) }
            .group_by { |node| let_name(node).to_s.gsub(INDEX_REGEX, '') }
            .values
            .filter { |lets| lets.count > cop_config['MaxRepeats'] }
            .flatten
        end
      end
    end
  end
end
