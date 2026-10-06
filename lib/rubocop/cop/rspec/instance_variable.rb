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
      #   # good - an instance variable of a class whose body the spec opens,
      #   # here through rspec-rails' `controller`
      #   describe MyController do
      #     controller do
      #       def index
      #         render json: @resource
      #       end
      #     end
      #   end
      #
      # @example with AssignmentOnly configuration
      #   # rubocop.yml
      #   # RSpec/InstanceVariable:
      #   #   AssignmentOnly: true
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
      class InstanceVariable < Base
        include TopLevelGroup

        MSG = 'Avoid instance variables - use let, ' \
              'a method call, or a local variable (if possible).'

        # @!method dynamic_class?(node)
        def_node_matcher :dynamic_class?, <<~PATTERN
          (block (send (const nil? :Class) :new ...) ...)
        PATTERN

        # @!method reopened_class?(node)
        def_node_matcher :reopened_class?, <<~PATTERN
          (block (send _ {:class_eval :module_eval} ...) ...)
        PATTERN

        # @!method custom_matcher?(node)
        def_node_matcher :custom_matcher?, <<~PATTERN
          (block {
            (send nil? :matcher sym)
            (send (const (const nil? :RSpec) :Matchers) :define sym)
          } ...)
        PATTERN

        # @!method ivar_usage(node)
        def_node_search :ivar_usage, '$(ivar $_)'

        # @!method ivar_assigned?(node)
        def_node_search :ivar_assigned?, '(ivasgn % ...)'

        def on_top_level_group(node)
          ivar_usage(node) do |ivar, name|
            next if valid_usage?(ivar)
            next if assignment_only? && !ivar_assigned?(node, name)

            add_offense(ivar)
          end
        end

        private

        def valid_usage?(node)
          inside_example = false

          node.each_ancestor(:block) do |block|
            return true if opens_another_body?(block, node, inside_example)

            inside_example ||= example_scope?(block)
          end

          false
        end

        def opens_another_body?(block, node, inside_example)
          return false unless in_body?(block, node)

          dynamic_class?(block) || reopened_class?(block) ||
            custom_matcher?(block) || (!inside_example && class_body?(block))
        end

        def in_body?(block, node)
          block.body&.source_range&.contains?(node.source_range)
        end

        def class_body?(node)
          !example_scope?(node) && defines_method?(node.body)
        end

        def defines_method?(body)
          statements = body.begin_type? ? body.children : [body]
          statements.any?(&:any_def_type?)
        end

        # A `def` in an example group belongs to the example group, so the
        # instance variables in it are the example's and stay flagged.
        def example_scope?(node)
          spec_group?(node) || example?(node) || hook?(node) ||
            let?(node) || subject?(node) || include?(node)
        end

        def assignment_only?
          cop_config['AssignmentOnly']
        end
      end
    end
  end
end
