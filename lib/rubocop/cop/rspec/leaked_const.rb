module RuboCop
  module Cop
    module RSpec
      # Check that constants are not being defined in a way that pollutes the global namespace.
      #
      # Prefer stub_const and anonymous classes.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     class Foo
      #       BAR = 1
      #     end
      #   end
      #
      #   # good
      #   describe MyClass do
      #     before do
      #       stub_const('Foo::BAR', 1)
      #     end
      #   end
      class LeakedConst < Cop
        MSG = 'Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.'.freeze

        def_node_matcher :stubbed_constant, <<-PATTERN
          (begin (send nil :stub_const $_ ...) ...)
        PATTERN

        def on_class(node)
          const_node, _superclass, body = *node
          _const, const_symbol = *const_node

          stubbed_constant(node.parent) do |const_name|
            const_name = *const_name
            return if const_name.include?(const_symbol.to_s)
          end

          add_offense(node, :expression, MSG)
        end
      end
    end
  end
end
