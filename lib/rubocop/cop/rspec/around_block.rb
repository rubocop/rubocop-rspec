module RuboCop
  module Cop
    module RSpec
      # Checks that around blocks actually run the test.
      #
      # @example
      #   # bad
      #   around do
      #     some_method
      #   end
      #
      #   around do |test|
      #     some_method
      #   end
      #
      #   # good
      #   around do |test|
      #     some_method
      #     test.call
      #   end
      #
      #   around do |test|
      #     some_method
      #     test.run
      #   end
      class AroundBlock < Cop
        MSG_NO_ARG = 'Test object should be passed to around block'.freeze
        MSG_UNUSED_ARG = 'You should call `%<arg>s.call` ' \
                          'or `%<arg>s.run`'.freeze

        def_node_matcher :scoped_hook, <<-PATTERN
        (block (send nil :around (sym {:each :example})) $(args ...) ...)
        PATTERN

        def_node_matcher :unscoped_hook, <<-PATTERN
        (block (send nil :around) $(args ...) ...)
        PATTERN

        def_node_search :find_arg_usage, '(lvar $_)'

        def on_block(node)
          hook(node) do |parameters|
            missing_parameters(parameters) do
              add_offense(node, :expression, MSG_NO_ARG)
              return
            end

            unused_parameters(parameters) do |param, name|
              add_offense(param, :expression, format(MSG_UNUSED_ARG, arg: name))
            end
          end
        end

        private

        def missing_parameters(node)
          yield if node.children[0].nil?
        end

        def unused_parameters(node)
          first_arg = node.children[0]
          param, _methods, _args = *first_arg
          start = node.parent

          find_arg_usage(start) do |name|
            return if param == name
          end

          yield first_arg, param
        end

        def hook(node, &block)
          scoped_hook(node, &block) || unscoped_hook(node, &block)
        end
      end
    end
  end
end
