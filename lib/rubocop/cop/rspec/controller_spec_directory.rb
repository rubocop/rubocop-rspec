# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Discourages specs in `spec/controllers/` directories.
      #
      # Controller specs are a legacy pattern that couples tests to
      # implementation details. Request specs test the full stack and
      # are more maintainable.
      #
      # This cop flags any top-level example group located in a
      # `spec/controllers/` directory. Use the `Include` configuration
      # to control which paths are checked.
      #
      # @example
      #   # bad - spec/controllers/users_controller_spec.rb
      #   RSpec.describe UsersController do
      #     # ...
      #   end
      #
      #   # good - spec/requests/users_spec.rb
      #   RSpec.describe 'Users', type: :request do
      #     # ...
      #   end
      #
      # @see RSpec/ControllerSpecType
      #
      class ControllerSpecDirectory < Base
        include TopLevelGroup

        MSG = 'Controller spec directories are deprecated. ' \
              'Move specs to `spec/requests/` and use `type: :request`.'

        def on_top_level_group(node)
          add_offense(node.send_node)
        end
      end
    end
  end
end
