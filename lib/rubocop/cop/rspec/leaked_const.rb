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

        def_node_matcher :stub_const, <<-PATTERN
          (begin (send nil :stub_const $_ ...) ...)
        PATTERN

        def_node_search :module_name, <<-PATTERN
          (module (const nil $_) ...)
        PATTERN

        def on_class(node)
          namespace = class_name(node)

          node.each_ancestor(:begin).each do |block_ancestor|
            stub_const(block_ancestor) do |stubbed_const_name|
              _const_type, stubbed_const_name = *stubbed_const_name
              return if namespace.include?(stubbed_const_name.to_s)
            end
          end

          add_offense(node, :expression, MSG)
        end

        private

        def class_name(node)
          class_node, _body = *node
          _class, class_name = *class_node

          module_names = node.each_ancestor(:module).flat_map do |parent_module|
            module_name(parent_module)
          end + [class_name]
          module_names.compact.join('::')
        end
      end
    end
  end
end
