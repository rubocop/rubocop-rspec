# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Enforce that subject is the first definition in the test.
      #
      # @example
      #   # bad
      #   let(:params) { blah }
      #   subject { described_class.new(params) }
      #
      #   before { do_something }
      #   subject { described_class.new(params) }
      #
      #   it { expect_something }
      #   subject { described_class.new(params) }
      #   it { expect_something_else }
      #
      #
      #   # good
      #   subject { described_class.new(params) }
      #   let(:params) { blah }
      #
      #   # good
      #   subject { described_class.new(params) }
      #   before { do_something }
      #
      #   # good
      #   subject { described_class.new(params) }
      #   it { expect_something }
      #   it { expect_something_else }
      #
      class LeadingSubject < Base
        extend AutoCorrector
        include InsideExampleGroup

        MSG = 'Declare `subject` above any other `%<offending>s` declarations.'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless subject?(node)
          return unless inside_example_group?(node)

          check_previous_nodes(node)
        end

        private

        def check_previous_nodes(node)
          offender = preceding_offender(node)
          return unless offender

          msg = format(MSG, offending: offender.method_name)
          add_offense(node, message: msg) do |corrector|
            target = move_target(node)
            autocorrect(corrector, node, target) if target
          end
        end

        # The declaration that makes this `subject` non-leading. Used only to
        # build the offense message and to decide whether to report an offense;
        # where the `subject` actually moves is decided by `move_target`.
        def preceding_offender(node)
          preceding_siblings(node).find { |sibling| offending?(sibling) }
        end

        # A `subject` may move above preceding `let`s/hooks, but never above
        # another `subject`. Walking preceding siblings in reverse, we stop at
        # the nearest `subject` and return the topmost offender after it, or
        # `nil` when a `subject` blocks the move (a later pass moves this one
        # once the `subject` above it has moved).
        def move_target(node)
          target = nil
          preceding_siblings(node).reverse_each do |sibling|
            break if subject?(sibling)

            target = sibling if offending?(sibling)
          end
          target
        end

        def preceding_siblings(node)
          parent(node).each_child_node.take_while do |sibling|
            !sibling.equal?(node)
          end
        end

        def parent(node)
          node.each_ancestor(:any_block).first.body
        end

        def autocorrect(corrector, node, sibling)
          RuboCop::RSpec::Corrector::MoveNode.new(
            node, corrector, processed_source
          ).move_before(sibling)
        end

        def offending?(node)
          let?(node) ||
            hook?(node) ||
            example?(node) ||
            spec_group?(node) ||
            include?(node)
        end
      end
    end
  end
end
