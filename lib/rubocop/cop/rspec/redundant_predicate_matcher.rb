# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for redundant predicate matcher.
      #
      # This cop checks for the following matchers:
      # - `be_all`
      # - `be_cover`
      # - `be_end_with`
      # - `be_eql`
      # - `be_equal`
      # - `be_exist`
      # - `be_exists`
      # - `be_include`
      # - `be_match`
      # - `be_respond_to`
      # - `be_start_with`
      #
      # This cop can be configured with `AllowedIdentifiers` option
      # to allow specific predicate matchers.
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
      # @ example `AllowedIdentifiers: ['be_exist']`
      #   # good
      #   expect(foo).to be_exist(bar)
      #
      class RedundantPredicateMatcher < Base
        include AllowedIdentifiers
        extend AutoCorrector

        MSG = 'Use `%<good>s` instead of `%<bad>s`.'
        RESTRICT_ON_SEND =
          %i[be_all be_cover be_end_with be_eql be_equal
             be_exist be_exists be_include be_match
             be_respond_to be_start_with].freeze

        def on_send(node)
          return if node.parent.block_type? || node.arguments.empty?
          return unless replaceable_arguments?(node)

          method_name = node.method_name.to_s
          return if allowed_identifiers?(method_name)

          replaced = replaced_method_name(method_name)
          add_offense(node, message: message(method_name,
                                             replaced)) do |corrector|
            unless node.method?(:be_all)
              corrector.replace(node.loc.selector, replaced)
            end
          end
        end

        private

        def message(bad_method, good_method)
          format(MSG, bad: bad_method, good: good_method)
        end

        def replaceable_arguments?(node)
          if node.method?(:be_all)
            node.first_argument.send_type?
          else
            true
          end
        end

        def replaced_method_name(method_name)
          name = method_name.to_s.delete_prefix('be_')
          if name == 'exists'
            'exist'
          else
            name
          end
        end

        def allowed_identifiers?(name)
          allowed_identifiers.include?(name)
        end

        def allowed_identifiers
          cop_config.fetch('AllowedIdentifiers', [])
        end
      end
    end
  end
end
