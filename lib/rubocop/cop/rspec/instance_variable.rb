# encoding: utf-8
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
        MESSAGE = 'Use `let` instead of an instance variable'
        EXAMPLE_GROUP_METHODS = [
          :example_group, :describe, :context, :xdescribe, :xcontext,
          :fdescribe, :fcontext, :shared_examples, :shared_context,
          :share_examples_for, :shared_examples_for, :feature
        ].freeze

        def on_block(node)
          method, _args, _body = *node
          _receiver, method_name, _object = *method
          @in_spec = true if EXAMPLE_GROUP_METHODS.include?(method_name)
        end

        def on_ivar(node)
          add_offense(node, :expression, MESSAGE) if @in_spec
        end
      end
    end
  end
end
