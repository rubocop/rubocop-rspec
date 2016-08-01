# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that the first argument to the top level describe is the tested
      # class or module.
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

        def_node_matcher :valid_describe?, <<-PATTERN
        {(send nil :describe const ...) (send nil :describe)}
        PATTERN

        def_node_matcher :describe_with_metadata, <<-PATTERN
        (send nil :describe
          !const
          ...
          (hash $...))
        PATTERN

        def_node_matcher :rails_metadata?, <<-PATTERN
        (pair
          (sym :type)
          (sym {:request :feature :routing :view}))
        PATTERN

        def on_top_level_describe(node, args)
          return if valid_describe?(node)

          describe_with_metadata(node) do |pairs|
            return if pairs.any?(&method(:rails_metadata?))
          end

          add_offense(args.first, :expression)
        end
      end
    end
  end
end
