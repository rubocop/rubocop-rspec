# encoding: utf-8

module Rubocop
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
    class RSpecDescribedClass < Cop
      include TopLevelDescribe

      MESSAGE = 'The first argument to describe should be the class or ' \
                'module being tested.'

      def on_top_level_describe(node, args)
        first_arg = args.first
        return unless !first_arg || first_arg.type != :const

        add_offense(first_arg || node, :expression, MESSAGE)
      end
    end
  end
end
