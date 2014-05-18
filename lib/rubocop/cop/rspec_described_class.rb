# encoding: utf-8

module Rubocop
  module Cop
    # If the first argument of describe is a class, the class is exposed to
    # each example via described_class - this should be used instead of
    # repeating the class.
    #
    # @example
    #   # bad
    #   describe MyClass do
    #     subject { MyClass.do_something }
    #   end
    #
    #   # good
    #   describe MyClass do
    #     subject { described_class.do_something }
    #   end
    class RSpecDescribedClass < Cop
      include TopLevelDescribe

      MESSAGE = 'Use `described_class` instead of `%s`'

      def on_block(node)
        method, _args, body = *node
        return unless top_level_describe?(method)

        _receiver, method_name, object = *method
        return unless method_name == :describe
        return unless object && object.type == :const

        inspect_children(body, object)
      end

      private

      def inspect_children(node, object)
        return unless node.is_a? Parser::AST::Node
        return if scope_change?(node) || node.type == :const

        node.children.each do |child|
          if child == object
            name =  object.loc.expression.source
            add_offense(child, :expression, format(MESSAGE, name))
            break
          end
          inspect_children(child, object)
        end
      end

      def scope_change?(node)
        [:def, :class, :module].include?(node.type)
      end
    end
  end
end
