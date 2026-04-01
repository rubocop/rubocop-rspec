# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Discourages explicit `type: :controller` metadata in specs.
      #
      # Controller specs are a legacy pattern that couples tests to
      # implementation details. Request specs test the full stack and
      # are more maintainable.
      #
      # @example
      #   # bad
      #   RSpec.describe UsersController, type: :controller do
      #     # ...
      #   end
      #
      #   # good
      #   RSpec.describe 'Users', type: :request do
      #     # ...
      #   end
      #
      # @see RSpec/ControllerSpecDirectory
      #
      class ControllerSpecType < Base
        include TopLevelGroup

        MSG = 'Controller specs are deprecated. ' \
              'Use request specs (`type: :request`) instead.'

        # @!method controller_type?(node)
        def_node_matcher :controller_type?, <<~PATTERN
          (hash <(pair (sym :type) (sym :controller)) ...>)
        PATTERN

        def on_top_level_group(node)
          return unless node.send_node.last_argument
          return unless controller_type?(node.send_node.last_argument)

          add_offense(node.send_node)
        end
      end
    end
  end
end
