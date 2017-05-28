module RuboCop
  module Cop
    module RSpec
      # Check that constants are not created in tests without cleanup.
      #
      # Prefer `Class.new` and/or `stub_const`.
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
        MSG = 'Ensure that new constants are cleaned up between specs'.freeze

        def_node_matcher :stub_const, <<-PATTERN
          (begin (send nil :stub_const $_ ...) ...)
        PATTERN

        def_node_search :module_name, <<-PATTERN
          (module (const nil $_) ...)
        PATTERN

        def on_class(node)
          namespace = class_name(node)

          stubbed_const = node.each_ancestor(:begin).any? do |block_ancestor|
            stub_const(block_ancestor) do |stubbed_const_name|
              _const_type, stubbed_const_name = *stubbed_const_name
              namespace.include?(stubbed_const_name.to_s)
            end
          end

          add_offense(node, :expression, MSG) unless stubbed_const
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
