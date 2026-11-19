# frozen_string_literal: true

module RuboCop
  module Cop
    # NOTE: Originally based on the `Rails/Output` cop.
    module RSpec
      # Checks for the use of output calls like puts and print in specs.
      #
      # @safety
      #   This autocorrection is marked as unsafe because, in rare cases, print
      #   statements can be used on purpose for integration testing and deleting
      #   them will cause tests to fail.
      #
      # @example
      #   # bad
      #   puts 'A debug message'
      #   pp 'A debug message'
      #   print 'A debug message'
      class Output < Base
        extend AutoCorrector

        MSG = 'Do not write to stdout in specs.'

        KERNEL_METHODS = %i[
          ap
          p
          pp
          pretty_print
          print
          puts
        ].to_set.freeze
        private_constant :KERNEL_METHODS

        IO_METHODS = %i[
          binwrite
          syswrite
          write
          write_nonblock
        ].to_set.freeze
        private_constant :IO_METHODS

        RESTRICT_ON_SEND = (KERNEL_METHODS + IO_METHODS).to_a.freeze

        # @!method output?(node)
        def_node_matcher :output?, <<~PATTERN
          (send nil? KERNEL_METHODS ...)
        PATTERN

        # @!method io_output?(node)
        def_node_matcher :io_output?, <<~PATTERN
          (send
            {
              (gvar #match_gvar?)
              (const {nil? cbase} {:STDOUT :STDERR})
            }
            IO_METHODS
            ...)
        PATTERN

        def on_send(node) # rubocop:disable Metrics/CyclomaticComplexity
          return if node.parent&.call_type? || node.block_node
          return if !output?(node) && !io_output?(node)
          return if node.arguments.any? { |arg| arg.type?(:hash, :block_pass) }

          add_offense(node) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def autocorrect(corrector, node)
          corrector.remove(node) if statement?(node)
        end

        def statement?(node)
          parent = node.parent
          return true if parent.nil? || parent.type?(:begin, :kwbegin)
          return branch?(parent, node) if parent.if_type?

          parent.type?(:any_block, :any_def) && parent.body.equal?(node)
        end

        def branch?(if_node, node)
          return false if if_node.ternary? || if_node.modifier_form?

          !if_node.condition.equal?(node)
        end

        def match_gvar?(sym)
          %i[$stdout $stderr].include?(sym)
        end
      end
    end
  end
end
