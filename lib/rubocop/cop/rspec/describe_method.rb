# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that the second argument to the top level describe is the tested
      # method name.
      #
      # @example
      #   # bad
      #   describe MyClass, 'do something' do
      #   end
      #
      #   # good
      #   describe MyClass, '#my_instance_method' do
      #   end
      #
      #   describe MyClass, '.my_class_method' do
      #   end
      class DescribeMethod < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MESSAGE = 'The second argument to describe should be the method ' \
                  "being tested. '#instance' or '.class'"
        METHOD_STRING_MATCHER = /^[\#\.].+/

        def on_top_level_describe(_node, args)
          second_arg = args[1]
          return unless second_arg && second_arg.type == :str
          return if METHOD_STRING_MATCHER =~ second_arg.children.first

          add_offense(second_arg, :expression, MESSAGE)
        end
      end
    end
  end
end
