# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Sort RSpec metadata alphabetically.
      #
      # @example
      #   # bad
      #   describe 'Something', :b, :a
      #   context 'Something', foo: 'bar', baz: true
      #   it 'works', :b, :a, foo: 'bar', baz: true
      #
      #   # good
      #   describe 'Something', :a, :b
      #   context 'Something', baz: true, foo: 'bar'
      #   it 'works', :a, :b, baz: true, foo: 'bar'
      #
      class SortMetadata < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Sort metadata alphabetically.'

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
              investigate(symbols, pairs.flatten)
            end
          end

          rspec_metadata(node) do |symbols, pairs|
            investigate(symbols, pairs.flatten)
          end
        end

        alias on_numblock on_block

        private

        def investigate(symbols, pairs)
          return if sorted?(symbols, pairs)

          crime_scene = crime_scene(symbols, pairs)
          add_offense(crime_scene) do |corrector|
            corrector.replace(crime_scene, replacement(symbols, pairs))
          end
        end

        def crime_scene(symbols, pairs)
          metadata = symbols + pairs

          range_between(
            metadata.first.loc.expression.begin_pos,
            metadata.last.loc.expression.end_pos
          )
        end

        def replacement(symbols, pairs)
          (sort_symbols(symbols) + sort_pairs(pairs)).map(&:source).join(', ')
        end

        def sorted?(symbols, pairs)
          symbols == sort_symbols(symbols) && pairs == sort_pairs(pairs)
        end

        def sort_pairs(pairs)
          pairs.sort_by { |pair| pair.key.source.downcase }
        end

        def sort_symbols(symbols)
          symbols.sort_by do |symbol|
            if %i[str sym].include?(symbol.type)
              symbol.value.to_s.downcase
            else
              symbol.source.downcase
            end
          end
        end
      end
    end
  end
end
