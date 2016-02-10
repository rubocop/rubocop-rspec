# encoding: utf-8

module RuboCop
  module Cop
    module RSpec
      # Pefer instance doubles over stubbing any instance of a class
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     before { allow_any_instance_of(MyClass).to receive(:foo) }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     let(:my_instance) { instance_double(MyClass) }
      #
      #     before do
      #       allow(MyClass).to receive(:new).and_return(my_instance)
      #       allow(my_instance).to receive(:foo)
      #     end
      #   end
      class AnyInstance < Cop
        MESSAGE = 'Avoid stubbing using `%{method}`'

        ANY_INSTANCE_METHODS = [
          :any_instance,
          :allow_any_instance_of,
          :expect_any_instance_of
        ]

        def on_send(node)
          _receiver, method_name, *_args = *node
          return unless ANY_INSTANCE_METHODS.include?(method_name)

          add_offense(node, :expression,
                      format(MESSAGE % { method: method_name },
                             node.loc.expression.source
                            )
                     )
        end
      end
    end
  end
end
