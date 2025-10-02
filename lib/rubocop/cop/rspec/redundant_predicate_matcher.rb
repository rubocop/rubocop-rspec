# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for redundant predicate matcher.
      #
      # This cop configures the mapping of redundant predicate matchers
      # and their preferable alternatives via `SupportedMethods` option.
      #
      # @example
      #   # bad
      #   expect(foo).to be_exist(bar)
      #   expect(foo).not_to be_include(bar)
      #   expect(foo).to be_all(bar)
      #
      #   # good
      #   expect(foo).to exist(bar)
      #   expect(foo).not_to include(bar)
      #   expect(foo).to all be(bar)
      #
      # @example `SupportedMethods: {be_exist: exist, be_include: include}`
      #  # good
      #  expect(foo).to exist(bar)
      #  expect(foo).not_to include(bar)
      #
      #  # bad
      #  expect(foo).to all be(bar)
      #
      class RedundantPredicateMatcher < Base
        extend AutoCorrector

        MSG = 'Use `%<good>s` instead of `%<bad>s`.'
        UNSUPPORTED_AUTOCORRECT_METHODS = %w[be_all].freeze

        def on_send(node)
          return if node.parent.nil?
          return if node.parent.block_type? || node.arguments.empty?

          method_name = node.method_name.to_s
          return unless supported_methods.key?(method_name)
          return unless valid_arguments?(node)

          register_offense(node, method_name)
        end

        private

        def valid_arguments?(node)
          return true unless node.method?(:be_all)

          node.first_argument.send_type?
        end

        def register_offense(node, method_name)
          replacement = supported_methods[method_name]

          add_offense(node, message: message(method_name,
                                             replacement)) do |corrector|
            unless UNSUPPORTED_AUTOCORRECT_METHODS.include?(method_name)
              corrector.replace(node.loc.selector, replacement)
            end
          end
        end

        def message(bad_method, good_method)
          format(MSG, bad: bad_method, good: good_method)
        end

        def supported_methods
          @supported_methods ||= cop_config.fetch('SupportedMethods', {})
        end
      end
    end
  end
end
