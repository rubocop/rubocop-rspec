# frozen_string_literal: true

module RuboCop
  module Cop
    # NOTE: Originally based on the `Rails/Output` cop.
    module RSpec
      # Checks for the use of output calls like puts and print in specs.
      #
      # @example
      #   # bad
      #   puts 'A debug message'
      #   pp 'A debug message'
      #   print 'A debug message'
      class Output < Base
        include RangeHelp

        MSG = 'Do not write to stdout in specs.'
        RESTRICT_ON_SEND = %i[ap p pp pretty_print print puts binwrite syswrite
                              write write_nonblock].freeze

        # @!method output?(node)
        def_node_matcher :output?, <<~PATTERN
          (send nil? {:ap :p :pp :pretty_print :print :puts} ...)
        PATTERN

        # @!method io_output?(node)
        def_node_matcher :io_output?, <<~PATTERN
          (send
            {
              (gvar #match_gvar?)
              (const {nil? cbase} {:STDOUT :STDERR})
            }
            {:binwrite :syswrite :write :write_nonblock}
            ...)
        PATTERN

        def on_send(node) # rubocop:disable Metrics/CyclomaticComplexity
          return if node.parent&.call_type? || node.block_node
          return if !output?(node) && !io_output?(node)
          return if node.arguments.any? { |arg| arg.type?(:hash, :block_pass) }

          range = offense_range(node)

          add_offense(range)
        end

        private

        def match_gvar?(sym)
          %i[$stdout $stderr].include?(sym)
        end

        def offense_range(node)
          if node.receiver
            range_between(node.source_range.begin_pos,
                          node.loc.selector.end_pos)
          else
            node.loc.selector
          end
        end
      end
    end
  end
end
