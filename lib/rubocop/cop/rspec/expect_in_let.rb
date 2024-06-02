# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not use `expect` in let.
      #
      # @example
      #   # bad
      #   let(:foo) do
      #     expect(something).to eq 'foo'
      #   end
      #
      #   # good
      #   it do
      #     expect(something).to eq 'foo'
      #   end
      #
      class ExpectInLet < Base
        MSG = 'Do not use `%<expect>s` in let'

        # @!method expectation(node)
        def_node_search :expectation, '(send nil? #Expectations.all ...)'

        def on_block(node)
          return unless let?(node)
          return if node.body.nil?

          expectation(node.body) do |expect|
            add_offense(expect.loc.selector, message: message(expect))
          end
        end

        alias on_numblock on_block

        private

        def message(expect)
          format(MSG, expect: expect.method_name)
        end
      end
    end
  end
end
