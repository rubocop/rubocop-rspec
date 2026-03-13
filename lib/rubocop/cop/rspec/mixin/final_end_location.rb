# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps find the true end location of nodes which might contain heredocs.
      module FinalEndLocation
        def final_end_location(start_node)
          heredoc_endings =
            start_node.each_node(:any_str)
              .select(&:heredoc?)
              .map { |node| node.loc.heredoc_end }

          end_loc = start_node.loc.end || start_node.source_range.end
          [end_loc, *heredoc_endings].max_by(&:line)
        end
      end
    end
  end
end
