# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Use string value when setting the class attribute explicitly.
        #
        # @example
        #   # bad
        #   factory :foo, class: Foo do
        #   end
        #
        #   # good
        #   factory :foo, class: 'Foo' do
        #   end
        class FactoryClassName < Cop
          MSG = "Pass '%<class_name>s' instead of %<class_name>s."

          def_node_matcher :class_name, <<~PATTERN
            (send _ :factory _ (hash <(pair (sym :class) $(const ...)) ...>))
          PATTERN

          def on_send(node)
            class_name(node) do |cn|
              add_offense(cn, message: format(MSG, class_name: cn.const_name))
            end
          end

          def autocorrect(node)
            lambda do |corrector|
              corrector.replace(node.loc.expression, "'#{node.source}'")
            end
          end
        end
      end
    end
  end
end
