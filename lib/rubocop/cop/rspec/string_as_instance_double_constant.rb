# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not use a string as `instance_double` constant.
      #
      # @safety
      #   This cop is unsafe because the correction requires loading the class.
      #   Loading before stubbing causes RSpec to only allow instance methods
      #   to be stubbed.
      #
      # @example
      #   # bad
      #   instance_double('User', name: 'John')
      #
      #   # good
      #   instance_double(User, name: 'John')
      #
      class StringAsInstanceDoubleConstant < Base
        extend AutoCorrector

        MSG = 'Do not use a string as `instance_double` constant.'
        RESTRICT_ON_SEND = %i[instance_double].freeze

        # @!method stringified_instance_double_const?(node)
        def_node_matcher :stringified_instance_double_const?, <<~PATTERN
          (send nil? :instance_double $str ...)
        PATTERN

        def on_send(node)
          stringified_instance_double_const?(node) do |args_node|
            add_offense(args_node) do |corrector|
              autocorrect(corrector, args_node)
            end
          end
        end

        def autocorrect(corrector, node)
          corrector.replace(node, node.value)
        end
      end
    end
  end
end
