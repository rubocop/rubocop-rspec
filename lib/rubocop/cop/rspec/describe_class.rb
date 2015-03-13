# encoding: utf-8

module RuboCop
  module Cop
    module RSpec
      # Check that the first argument to the top level describe is the tested
      # class or module.
      #
      # @example
      #   # bad
      #   describe 'Do something' do
      #   end
      #
      #   # good
      #   describe TestedClass do
      #   end
      class DescribeClass < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MESSAGE = 'The first argument to describe should be the class or ' \
                  'module being tested.'

        def on_top_level_describe(_node, args)
          return if args[0] && args[0].type == :const

          return if request_spec?(args[1]) || feature_spec?(args[1])

          add_offense(args[0], :expression, MESSAGE)
        end

        private

        def request_spec?(node)
          return false unless node

          node.loc.expression.source == 'type: :request' || ':type => :request'
        end

        def feature_spec?(node)
          return false unless node

          node.loc.expression.source == 'type: :feature' || ':type => :feature'
        end
      end
    end
  end
end
