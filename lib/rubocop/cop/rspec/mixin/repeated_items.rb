# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps find repeated items in a collection
      #
      # Provides a generic method to find repeated items by grouping them
      # by a key and returning pairs of [item, repeated_lines] for items
      # that appear more than once.
      module RepeatedItems
        # Groups items by key and returns only groups with more than one item
        #
        # @param items [Enumerable] the filtered collection to group
        # @param key_proc [Proc] block returning the grouping key for each item
        # @return [Array<Array>] array of groups containing more than one item
        #   that share the same key and there are multiple items in the group
        def find_repeated_groups(items, key_proc:)
          items
            .group_by(&key_proc)
            .values
            .reject(&:one?)
        end

        # Maps a group of items to pairs of [item, repeated_lines]
        #
        # @param items [Array] array of items that share the same key
        # @return [Array<Array>] array of [item, repeated_lines] pairs
        def add_repeated_lines(items)
          repeated_lines = items.map(&:first_line)
          items.map { |item| [item, repeated_lines - [item.first_line]] }
        end
      end
    end
  end
end
