# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # When you have to assign a variable instead of using an instance
      # variable, use let.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     before { @foo = [] }
      #     it { expect(@foo).to be_empty }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     let(:foo) { [] }
      #     it { expect(foo).to be_empty }
      #   end
      class InstanceVariable < Cop
        include RuboCop::RSpec::SpecOnly, RuboCop::RSpec::Language

        MESSAGE = 'Use `let` instead of an instance variable'.freeze

        EXAMPLE_GROUP_METHODS = ExampleGroups::ALL + SharedGroups::ALL

        def_node_matcher :spec_group?, <<-PATTERN
          (block (send _ {#{EXAMPLE_GROUP_METHODS.to_node_pattern}} ...) ...)
        PATTERN

        def_node_search :ivar_usage, '$(ivar $_)'

        def on_block(node)
          return unless spec_group?(node)

          ivar_usage(node) do |ivar, _|
            add_offense(ivar, :expression, MESSAGE)
          end
        end
      end
    end
  end
end
