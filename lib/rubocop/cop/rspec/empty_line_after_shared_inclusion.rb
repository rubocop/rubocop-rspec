# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for empty line after shared example inclusion.
      #
      # @example
      #   # bad
      #   RSpec.describe User do
      #     include_context 'with_authentication'
      #     it { does_something }
      #   end
      #
      #   # bad
      #   RSpec.describe User do
      #     it_behaves_like 'a sortable'
      #     it { does_something }
      #   end
      #
      #   # good
      #   RSpec.describe User do
      #     include_context 'with_authentication'
      #
      #     it { does_something }
      #   end
      #
      #   # good - multiple shared example inclusions grouped together
      #   RSpec.describe User do
      #     include_context 'with_authentication'
      #     include_context 'with_authorization'
      #
      #     it { does_something }
      #   end
      #
      class EmptyLineAfterSharedInclusion < Base
        include EmptyLineSeparation
        extend AutoCorrector

        MSG = 'Add an empty line after shared example inclusion.'

        # @!method spec_group?(node)
        def_node_matcher :spec_group?, <<~PATTERN
          (block (send #rspec?
               {#SharedGroups.all #ExampleGroups.all}
            ...) ...)
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless spec_group?(node)

          body = node.body
          return if body.nil? || !body.begin_type?

          check_inclusions(body)
        end

        private

        def check_inclusions(body)
          body.each_child_node do |child|
            next unless include?(child)
            next if consecutive_inclusion?(child)

            missing_separating_line_offense(child) do |_method|
              MSG
            end
          end
        end

        def consecutive_inclusion?(node)
          sibling = node.right_sibling
          sibling && include?(sibling)
        end
      end
    end
  end
end
