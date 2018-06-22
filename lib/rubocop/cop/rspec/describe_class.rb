# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that the first argument to the top level describe is a constant.
      #
      # @example
      #   # bad
      #   describe 'Do something' do
      #   end
      #
      #   # good
      #   describe TestedClass do
      #   end
      #
      #   describe "A feature example", type: :feature do
      #   end
      class DescribeClass < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG = 'The first argument to describe should be '\
              'the class or module being tested.'.freeze

        FIRST_ARGUMENT_REQUIRED_MSG =
          'The first argument to describe is required.'.freeze

        def_node_matcher :describe_with_const?, <<-PATTERN
          (send {(const nil? :RSpec) nil?} :describe const ...)
        PATTERN

        def_node_matcher :describe_with_metadata, <<-PATTERN
          (send {(const nil? :RSpec) nil?} :describe
            !const
            ...
            (hash $...))
        PATTERN

        def_node_matcher :rails_metadata?, <<-PATTERN
          (pair
            (sym :type)
            (sym {:request :feature :system :routing :view}))
        PATTERN

        def_node_matcher :shared_group?, SharedGroups::ALL.block_pattern

        def on_top_level_describe(node, args)
          return if shared_group?(root_node)
          return if valid_describe?(node)

          unless node.arguments?
            return add_offense(node, location: :expression,
                                     message: FIRST_ARGUMENT_REQUIRED_MSG)
          end

          describe_with_metadata(node) do |pairs|
            return if pairs.any?(&method(:rails_metadata?))
          end

          add_offense(args.first, location: :expression)
        end

        private

        def valid_describe?(node)
          return true unless node.arguments? || first_argument_required?

          describe_with_const?(node)
        end

        def first_argument_required?
          cop_config.fetch('FirstArgumentRequired', false)
        end
      end
    end
  end
end
