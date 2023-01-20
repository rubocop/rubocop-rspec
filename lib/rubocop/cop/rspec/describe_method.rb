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
      #
      class DescribeMethod < Base
        include TopLevelGroup

        MSG = 'The second argument to describe should be the method ' \
              "being tested. '#instance' or '.class'."

        # @!method second_argument(node)
        def_node_matcher :second_argument, <<~PATTERN
          (block
            (send #rspec? :describe _first_argument $_ ...)
          ...)
        PATTERN

        # @!method not_method_name?(node)
        def_node_matcher :not_method_name?, <<~PATTERN
          {(str !#method_name?) (dstr (str !#method_name?) ...)}
        PATTERN

        def on_top_level_group(node)
          second_argument(node) do |argument|
            add_offense(argument) if not_method_name?(argument)
          end
        end

        private

        def method_name?(description)
          description.start_with?('.', '#')
        end
      end
    end
  end
end
