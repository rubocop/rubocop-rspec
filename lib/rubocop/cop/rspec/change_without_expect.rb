# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for `change` matcher usage without an `expect` block.
      #
      # This cop only considered a matcher if it is chained with
      # `from`, `by`, `by_at_least`, or `by_at_most`.
      #
      # @example
      #   # bad
      #   it 'changes the count' do
      #     change(Counter, :count).by(1)
      #   end
      #
      #   # bad
      #   it 'changes the count' do
      #     change(Counter, :count).by_at_least(1)
      #   end
      #
      #   # bad
      #   it 'changes the count' do
      #     change(Counter, :count).by_at_most(1)
      #   end
      #
      #   # bad
      #   it 'changes the count' do
      #     change(Counter, :count).from(0)
      #   end
      #
      #   # bad
      #   it 'changes the count' do
      #     change(Counter, :count).from(0).to(1)
      #   end
      #
      #   # good - no chained matchers
      #   it 'changes the count' do
      #     change(Counter, :count)
      #   end
      #
      #   # good - ignore not change matcher
      #   it 'changes the count' do
      #     change(Counter, :count).from(0).by(1)
      #   end
      #
      #   # good - within expect block
      #   it 'changes the count' do
      #     expect { subject }.to change(Counter, :count).by(1)
      #   end
      #
      class ChangeWithoutExpect < RuboCop::Cop::Base
        include RangeHelp

        MSG = 'Use `change` matcher within an `expect` block.'
        RESTRICT_ON_SEND = [:change].freeze
        SINGLE_RESTRICTED_METHODS = %i[by by_at_least by_at_most from].freeze

        # @!method expectation?(node)
        def_node_search :expectation?, <<~PATTERN
          (send
            {
              (block (send nil? :expect ...) ...)
              (send nil? :expect ...)
            }
            {:to :not_to}
            ...)
        PATTERN

        def on_send(node)
          return if within_expectation?(node)
          return unless offensive_chain?(node)

          add_offense(node)
        end

        private

        def offensive_chain?(node)
          chain_methods = chain_methods(node)
          return false if chain_methods.empty?

          # Case 1: single restricted method (by, by_at_least, by_at_most, from)
          if chain_methods.size == 1 &&
              SINGLE_RESTRICTED_METHODS.include?(chain_methods.first)
            return true
          end

          # Case 2: exactly from().to() pattern
          if chain_methods.size == 2 &&
              chain_methods.first == :from &&
              chain_methods.last == :to
            return true
          end

          false
        end

        def chain_methods(node)
          methods = []
          chain = node

          while chain.parent.send_type?
            chain = chain.parent
            methods << chain.method_name
          end

          methods
        end

        def within_expectation?(node)
          node.each_ancestor(:send).any? do |ancestor|
            expectation?(ancestor)
          end
        end
      end
    end
  end
end
