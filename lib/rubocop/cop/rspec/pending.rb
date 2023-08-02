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
      # @example `AllowedIdentifiers: ['run_test!']`
      #   # good
      #   response '201', 'foo created' do
      #     run_test!
      #   end
      #
      # @example `AllowedPatterns: ['it']`
      #   # good
      #   describe SomeService do
      #     it
      #     xit 'test' do
      #     end
      #   end
      #
      class Pending < Base
        include SkipOrPending
        include AllowedIdentifiers
        include AllowedPattern

        MSG = 'Pending spec found.'

        # @!method skippable?(node)
        def_node_matcher :skippable?, <<~PATTERN
          {
            (send #rspec? #ExampleGroups.regular ...)
            #skippable_example?
          }
        PATTERN

        # @!method skippable_example?(node)
        def_node_matcher :skippable_example?, <<~PATTERN
          (send nil? #Examples.regular ...)
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
          return if allowed?(node.method_name.to_s)

          add_offense(node)
        end

        private

        def skipped?(node)
          skippable?(node) && skipped_in_metadata?(node) ||
            skipped_regular_example_without_body?(node)
        end

        def skipped_regular_example_without_body?(node)
          skippable_example?(node) && !node.block_node
        end

        def allowed?(method_name)
          allowed_identifier?(method_name) ||
            matches_allowed_pattern?(method_name)
        end
      end
    end
  end
end
