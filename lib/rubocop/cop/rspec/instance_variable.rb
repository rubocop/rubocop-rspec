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
      #   # good - instance variables of a class whose body the spec opens,
      #   # here through rspec-rails' `controller`
      #   describe MyController do
      #     controller do
      #       before_action { head :forbidden unless @resource }
      #
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
          (block (send (const nil? {:Class :Module}) :new ...) ...)
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
          node.each_ancestor(:block).any? do |block|
            in_body?(block, node) &&
              (dynamic_class?(block) || reopened_class?(block) ||
               custom_matcher?(block) || class_body?(block))
          end
        end

        def in_body?(block, node)
          block.body&.source_range&.contains?(node.source_range)
        end

        def class_body?(block)
          defines_method?(block.body) && !declares_rspec_dsl?(block)
        end

        def defines_method?(body)
          statements = body.begin_type? ? body.children : [body]
          statements.any?(&:any_def_type?)
        end

        def declares_rspec_dsl?(block)
          block.each_node(:block).any? { |node| rspec_dsl?(node) }
        end

        def rspec_dsl?(node)
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
