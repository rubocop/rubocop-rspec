# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helper methods to find RSpec metadata.
      module Metadata
        extend RuboCop::NodePattern::Macros

        include RuboCop::RSpec::Language

        # @!method rspec_metadata(node)
        def_node_matcher :rspec_metadata, <<~PATTERN
          (block
            (send
              #rspec? {#Examples.all #ExampleGroups.all #SharedGroups.all #Hooks.all} _ ${send str sym}* (hash $...)?)
            ...)
        PATTERN

        # @!method rspec_configure(node)
        def_node_matcher :rspec_configure, <<~PATTERN
          (block (send #rspec? :configure) (args (arg $_)) ...)
        PATTERN

        # @!method metadata_in_block(node)
        def_node_search :metadata_in_block, <<~PATTERN
          (send (lvar %) #Hooks.all _ ${send str sym}* (hash $...)?)
        PATTERN

        def on_block(node)
          rspec_configure(node) do |block_var|
            metadata_in_block(node, block_var) do |symbols, pairs|
              on_metadata(symbols, pairs.flatten)
            end
          end

          rspec_metadata(node) do |symbols, pairs|
            on_metadata(symbols, pairs.flatten)
          end
        end
        alias on_numblock on_block

        def on_metadata(_symbols, _pairs)
          raise ::NotImplementedError
        end
      end
    end
  end
end
