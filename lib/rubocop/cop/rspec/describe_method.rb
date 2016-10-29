# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that the second argument to `describe` specifies a method.
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
        include RuboCop::RSpec::TopLevelDescribe,
                RuboCop::RSpec::Util

        MESSAGE = 'The second argument to describe should be the method ' \
                  "being tested. '#instance' or '.class'".freeze
        METHOD_STRING_MATCHER = /^[\#\.].+/

        def on_top_level_describe(_node, (_, second_arg))
          return unless second_arg && second_arg.type.equal?(:str)
          return if METHOD_STRING_MATCHER =~ one(second_arg.children)

          add_offense(second_arg, :expression, MESSAGE)
        end
      end
    end
  end
end
