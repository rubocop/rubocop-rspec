# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not set up test data using indexes (e.g., `item_1`, `item_2`).
      #
      # It makers reading the test harder because it's not clear what exactly
      # is tested by this particular example.
      #
      # @example
      #   # bad
      #   let(:item_1) { create(:item) }
      #   let(:item_2) { create(:item) }
      #
      #   let(:item_1) { create(:item, visible: true) }
      #   let(:item_2) { create(:item, visible: false) }
      #
      #   before do
      #     item_1 = create(:item)
      #     item_2 = create(:item)
      #   end
      #
      #   # good
      #   let(:items) { create_list(:item, 2) }
      #
      #   let(:visible_item) { create(:item, visible: true) }
      #   let(:invisible_item) { create(:item, visible: false) }
      #
      #   before do
      #     create_list(:item, 2)
      #   end
      #
      class IndexedLet < Base
        MSG = 'This block declares indexed `let` statements: ' \
              '%<duplicates>s. Please give them meaningful names,' \
              ' use create_list or move creation to the `before` block.'

        # @!method describe_or_context(node)
        def_node_matcher :describe_or_context, <<~PATTERN
          (block (send nil? {:describe | :context} ...) _ (begin $...))
        PATTERN

        # @!method any_let(node)
        def_node_matcher :any_let, <<~PATTERN
          (block (send nil? {:let | :let! | :let_it_be} (sym $_)) _ ...)
        PATTERN

        # @!method before(node)
        def_node_matcher :before, <<~PATTERN
          (block (send nil? :before ...) _ (begin $...))
        PATTERN

        # @!method lvasgn(node)
        def_node_matcher :lvasgn, <<~PATTERN
          (lvasgn $_ ...)
        PATTERN

        def on_block(node)
          duplicated_names =
            if (chidlren = describe_or_context(node))
              find_duplicate_indexed_names(chidlren) { any_let(_1) }
            elsif (chidlren = before(node))
              find_duplicate_indexed_names(chidlren) { lvasgn(_1) }
            else
              []
            end

          return if duplicated_names.empty?

          register_offense(node, duplicated_names)
        end

        alias on_numblock on_block

        private

        def find_duplicate_indexed_names(candidates)
          candidates
            .filter_map { yield _1 }
            .map { |name| name.to_s.gsub(/_\d+/, '') }
            .group_by(&:itself)
            .filter { |_, lets| lets.count > cop_config['MaxRepeats'] }
            .map(&:first)
        end

        def register_offense(node, duplicated_indexed_names)
          duplicates = duplicated_indexed_names.map { "`#{_1}_x`" }.join(', ')
          message = format(MSG, duplicates: duplicates)

          add_offense(node, message: message)
        end
      end
    end
  end
end
