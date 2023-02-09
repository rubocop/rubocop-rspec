# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for any pending or skipped examples.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     it "should be true"
      #   end
      #
      #   describe MyClass do
      #     it "should be true", skip: true do
      #       expect(1).to eq(2)
      #     end
      #   end
      #
      #   describe MyClass do
      #     it "should be true" do
      #       pending
      #     end
      #   end
      #
      #   describe MyClass do
      #     xit "should be true" do
      #     end
      #   end
      #
      #   # good
      #   describe MyClass do
      #   end
      #
      class Pending < Base
        include SkipOrPending

        MSG = 'Pending spec found.'

        # @!method skippable?(node)
        def_node_matcher :skippable?, <<~PATTERN
          {
            (send #rspec? #ExampleGroups.regular ...)
            (send nil? #Examples.regular ...)
          }
        PATTERN

        # @!method pending_block?(node)
        def_node_matcher :pending_block?, <<~PATTERN
          {
            (send #rspec? #ExampleGroups.skipped ...)
            (send nil? {#Examples.skipped #Examples.pending} ...)
          }
        PATTERN

        def on_send(node)
          return unless pending_block?(node) || skipped?(node)

          add_offense(node)
        end

        private

        def skipped?(node)
          skippable?(node) && skipped_in_metadata?(node)
        end
      end
    end
  end
end
