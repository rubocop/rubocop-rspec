# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Avoid passing a Symbol as the first argument to `describe`
      #
      # @example
      #   # bad
      #   describe :my_method do
      #     ...
      #   end
      #
      #   # good
      #   describe '#my_method' do
      #     ...
      #   end
      #
      # See https://github.com/rspec/rspec-core/issues/1610
      class DescribeSymbol < RuboCop::Cop::Cop
        MSG = 'Avoid passing a Symbol as the first argument to ' \
              '`describe`'.freeze

        def on_send(node)
          return unless node.method_name == :describe

          arg_node = node.method_args.first

          return unless arg_node.sym_type?

          add_offense(arg_node, :expression, MSG)
        end
      end
    end
  end
end
