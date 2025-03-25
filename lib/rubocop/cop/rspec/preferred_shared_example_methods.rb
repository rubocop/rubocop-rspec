# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent method selection for shared examples.
      #
      # When defining shared examples there are multiple options for which
      # method that can be used (RSpec itself aliases `shared_examples`, and
      # additional aliases could be specified when using RSpec). This cop
      # enforces consistency with these aliases.
      #
      # There is separate configuration for defining shared examples
      # (`PreferredExamplesMethod`) and context (`PreferredContextMethod`).
      #
      # By default, each configuration option is unset, which allows any
      # methods provided in the `Language/SharedGroups` configuration.
      #
      # @example PreferredExamplesMethod: nil (default)
      #   # good
      #   shared_examples
      #   shared_examples_for
      #
      #   # good - with alias defined in Language/SharedGroups/Examples
      #   shared_scenarios
      #
      # @example PreferredExamplesMethod: shared_examples
      #   # bad
      #   shared_examples_for
      #
      #   # bad - with alias defined in Language/SharedGroups/Examples
      #   shared_scenarios
      #
      #   # good
      #   shared_examples
      #
      # @example PreferredContextMethod: nil (default)
      #   # good
      #   shared_context
      #
      #   # good - with alias defined in Language/SharedGroups/Context
      #   shared_scenarios
      #
      # @example PreferredContextMethod: shared_context
      #   # bad - with alias defined in Language/SharedGroups/Context
      #   shared_scenarios
      #
      #   # good
      #   shared_context
      #
      class PreferredSharedExampleMethods < Base
        extend AutoCorrector

        MSG = 'Prefer `%<prefer>s` over `%<current>s`.'

        # @!method shared_examples?(node)
        def_node_matcher :shared_examples?, <<~PATTERN
          (send #rspec? #SharedGroups.all ...)
        PATTERN

        def on_send(node)
          return unless shared_examples?(node)

          preferred_method_name = preferred_method_name(node.method_name)
          return unless preferred_method_name
          return if node.method?(preferred_method_name)

          selector = node.loc.selector
          message = format(
            MSG,
            prefer: preferred_method_name,
            current: node.method_name
          )

          add_offense(selector, message: message) do |corrector|
            corrector.replace(selector, preferred_method_name)
          end
        end

        private

        def preferred_method_name(method_name)
          if SharedGroups.examples(method_name)
            cop_config['PreferredExamplesMethod']
          else
            cop_config['PreferredContextMethod']
          end
        end
      end
    end
  end
end
