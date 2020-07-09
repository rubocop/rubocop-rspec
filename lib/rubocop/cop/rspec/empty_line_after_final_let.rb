# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after the last let block.
      #
      # @example
      #   # bad
      #   let(:foo) { bar }
      #   let(:something) { other }
      #   it { does_something }
      #
      #   # good
      #   let(:foo) { bar }
      #   let(:something) { other }
      #
      #   it { does_something }
      class EmptyLineAfterFinalLet < Cop
        extend AutoCorrector
        include RuboCop::RSpec::BlankLineSeparation

        MSG = 'Add an empty line after the last `let` block.'

        def on_block(node)
          return unless example_group_with_body?(node)

          latest_let = node.body.child_nodes.select { |child| let?(child) }.last

          return if latest_let.nil?
          return if last_child?(latest_let)

          missing_separating_line(latest_let) do |location|
            add_offense(location) do |corrector|
              corrector.insert_after(location.end, "\n")
            end
          end
        end
      end
    end
  end
end
