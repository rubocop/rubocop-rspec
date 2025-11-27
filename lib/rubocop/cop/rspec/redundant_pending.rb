# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for redundant `pending` or `skip` inside skipped examples.
      #
      # When an example is already skipped using `xit`, `xspecify`, `xexample`,
      # or `skip` metadata, adding `pending` or `skip` inside the example body
      # is redundant.
      #
      # @example
      #   # bad
      #   xit 'does something' do
      #     pending 'not yet implemented'
      #     expect(something).to be_truthy
      #   end
      #
      #   # bad
      #   xspecify do
      #     pending 'not yet implemented'
      #     expect(something).to be_truthy
      #   end
      #
      #   # bad
      #   it 'does something', :skip do
      #     pending 'not yet implemented'
      #     expect(something).to be_truthy
      #   end
      #
      #   # bad
      #   it 'does something', skip: true do
      #     skip 'not yet implemented'
      #     expect(something).to be_truthy
      #   end
      #
      #   # good
      #   xit 'does something' do
      #     expect(something).to be_truthy
      #   end
      #
      #   # good
      #   it 'does something', skip: 'not yet implemented' do
      #     expect(something).to be_truthy
      #   end
      #
      #   # good
      #   it 'does something' do
      #     pending 'not yet implemented'
      #     expect(something).to be_truthy
      #   end
      #
      class RedundantPending < Base
        MSG = 'Redundant `%<method>s` inside already skipped example. ' \
              'Remove `%<method>s` or use regular example method.'

        # @!method skipped_example?(node)
        def_node_matcher :skipped_example?, <<~PATTERN
          {
            (any_block (send _ #Examples.skipped ...) ...)
          }
        PATTERN

        # @!method skipped_by_metadata?(node)
        def_node_matcher :skipped_by_metadata?, <<~PATTERN
          {
            (any_block (send _ #Examples.all ... <(sym {:skip :pending}) ...>) ...)
            (any_block (send _ #Examples.all ... (hash <(pair (sym {:skip :pending}) !false) ...>)) ...)
          }
        PATTERN

        # @!method pending_or_skip_call?(node)
        def_node_matcher :pending_or_skip_call?, <<~PATTERN
          (send nil? ${:pending :skip} ...)
        PATTERN

        def on_block(node)
          check_example(node)
        end
        alias on_numblock on_block

        private

        def check_example(node)
          return unless skipped_example?(node) || skipped_by_metadata?(node)
          return unless node.body

          find_pending_or_skip(node.body) do |method_name|
            message = format(MSG, method: method_name)
            add_offense(node.body, message: message)
          end
        end

        def find_pending_or_skip(body, &block)
          first_statement = if body.begin_type?
                              body.children.first
                            else
                              body
                            end

          pending_or_skip_call?(first_statement, &block)
        end
      end
    end
  end
end
