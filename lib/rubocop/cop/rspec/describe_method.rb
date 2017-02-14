# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that describes specify methods.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     describe 'flowers' do; end
      #   end
      #
      #   describe MyClass, 'flowers' do
      #   end
      #
      #   # good
      #   describe MyClass do
      #     describe '#my_instance_method' do; end
      #   end
      #
      #   describe MyClass do
      #     describe '.my_class_method' do; end
      #   end
      #
      #   describe MyClass, '#my_instance_method' do
      #   end
      #
      #   describe MyClass, '.my_class_method' do
      #   end
      #
      # @example configuration
      #
      #   # .rubocop.yml
      #   RSpec/DescribeMethod:
      #     IgnoredDescribes:
      #     - flowers
      #     - stars
      #
      #   # bad
      #   describe MyClass do
      #     describe 'not_flowers_or_stars' do; end
      #   end
      #
      #   describe MyClass, 'not_flowers_or_stars' do
      #   end
      #
      #   # good
      #   describe MyClass do
      #     describe 'flowers' do; end
      #     describe 'stars' do; end
      #     describe '#some_method' do; end
      #     describe '.some_class_method' do; end
      #   end
      #
      #   describe MyClass, 'flowers' do
      #   end
      #
      class DescribeMethod < Cop
        include RuboCop::RSpec::TopLevelDescribe
        include RuboCop::RSpec::Util

        METHOD_STRING_MATCHER = /\A[\#\.].+/

        MSG = 'The second level describes should be the method '\
                  "being tested: '#instance' or '.class'.".freeze
        TOP_LEVEL_MSG = 'The second argument to describe should '\
                        'be the method being tested: '\
                        "'#instance' or '.class'.".freeze

        def on_top_level_describe(_node, (_, second_arg))
          return unless second_arg && second_arg.str_type?
          return if ignored_describe?(second_arg)
          return if METHOD_STRING_MATCHER =~ one(second_arg.children)

          add_offense(second_arg, :expression, TOP_LEVEL_MSG)
        end

        def on_block(node)
          describe, _described_class, body = described_constant(node)
          return unless describe
          return unless body

          describe_blocks(body).each do |describe_block|
            if describe_block.method_args.any?
              check_describe_arguments(describe_block)
            else
              add_offense(describe_block, :expression, MSG)
            end
          end
        end

        private

        def check_describe_arguments(describe_block)
          describe_block.method_args.each do |describe_argument|
            next if ignored_describe?(describe_argument)

            unless METHOD_STRING_MATCHER =~ describe_name(describe_argument)
              add_offense(describe_argument, :expression, MSG)
            end
          end
        end

        def ignored_describe?(describe_argument)
          return true unless describe_argument.str_type?

          ignored_names.include?(describe_name(describe_argument))
        end

        def describe_name(describe_argument)
          describe_argument.children.first
        end

        def describe_blocks(node)
          RuboCop::RSpec::ExampleGroup.new(node)
            .example_groups
            .select(&:describe?)
            .map(&:to_node)
        end

        def ignored_names
          cop_config.fetch('IgnoredDescribes', [])
        end
      end
    end
  end
end
