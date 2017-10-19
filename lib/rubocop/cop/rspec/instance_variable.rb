# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for instance variable usage in specs.
      #
      # This cop can be configured with the option `AssignmentOnly` which
      # will configure the cop to only register offenses on instance
      # variable usage if the instance variable is also assigned within
      # the spec
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
      #
      # @example with AssignmentOnly configuration
      #
      #   # rubocop.yml
      #   RSpec/InstanceVariable:
      #     AssignmentOnly: false
      #
      #   # bad
      #   describe MyClass do
      #     before { @foo = [] }
      #     it { expect(@foo).to be_empty }
      #   end
      #
      #   # allowed
      #   describe MyClass do
      #     it { expect(@foo).to be_empty }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     let(:foo) { [] }
      #     it { expect(foo).to be_empty }
      #   end
      #
      class InstanceVariable < Cop
        MSG = 'Use `let` instead of an instance variable.'.freeze

        EXAMPLE_GROUP_METHODS = ExampleGroups::ALL + SharedGroups::ALL

        def_node_matcher :spec_group?, EXAMPLE_GROUP_METHODS.block_pattern

        def_node_search :ivar_usage, '$(ivar $_)'

        def_node_search :ivar_assigned?, '(ivasgn % ...)'

        def on_block(node)
          return unless spec_group?(node)

          ivar_usage(node) do |ivar, name|
            return if assignment_only? && !ivar_assigned?(node, name)

            add_offense(ivar, location: :expression)
          end
        end

        private

        def assignment_only?
          cop_config['AssignmentOnly']
        end
      end
    end
  end
end
