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

        REQUEST_PAIR = s(:pair, s(:sym, :type), s(:sym, :request))
        FEATURE_PAIR = s(:pair, s(:sym, :type), s(:sym, :feature))
        ROUTING_PAIR = s(:pair, s(:sym, :type), s(:sym, :routing))
        VIEW_PAIR = s(:pair, s(:sym, :type), s(:sym, :view))

        MESSAGE = 'The first argument to describe should be the class or ' \
                  'module being tested.'.freeze

        def on_top_level_describe(_node, args)
          return if args.empty? || args.first.type.equal?(:const)

          return if args.any? do |arg|
            arg.children.any? do |n|
              [REQUEST_PAIR, FEATURE_PAIR, ROUTING_PAIR, VIEW_PAIR].include?(n)
            end
          end

          add_offense(args.first, :expression, MESSAGE)
        end
      end
    end
  end
end
