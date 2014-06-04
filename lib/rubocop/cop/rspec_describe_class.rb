# encoding: utf-8

module RuboCop
  module Cop
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
    class RSpecDescribeClass < Cop
      include RSpec::TopLevelDescribe

      MESSAGE = 'The first argument to describe should be the class or ' \
                'module being tested.'

      def on_top_level_describe(_node, args)
        return if args.first && args.first.type == :const
        add_offense(args.first, :expression, MESSAGE)
      end
    end
  end
end
