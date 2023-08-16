# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that spec files only include one test target object.
      #
      # @example
      #   # bad
      #   RSpec.describe User do
      #     # ...
      #     describe User::Admin do
      #       # ...
      #     end
      #   end
      #
      #   # bad
      #   RSpec.describe User do
      #     # ...
      #   end
      #   RSpec.describe Admin do
      #     # ...
      #   end
      #
      #   # good
      #   RSpec.describe User do
      #     # ...
      #   end
      #
      class MultipleTestTargetsPerSpecFile < Base
        MSG = 'Spec files should only include one test target object.'

        # @!method describe_classes(node)
        def_node_search :describe_classes, <<~PATTERN
          (block $(send #rspec? #ExampleGroups.all (const ...) ...) ...)
        PATTERN

        def on_investigation_end
          return unless processed_source.ast

          describes = describe_classes(processed_source.ast)
          return if describes.count <= 1

          describes.each do |node|
            add_offense(node)
          end
        end
      end
    end
  end
end
