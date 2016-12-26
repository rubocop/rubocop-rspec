# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that tests use `described_class`.
      #
      # If the first argument of describe is a class, the class is exposed to
      # each example via described_class - this should be used instead of
      # repeating the class.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     subject { MyClass.do_something }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     subject { described_class.do_something }
      #   end
      class DescribedClass < Cop
        include RuboCop::RSpec::TopLevelDescribe

        DESCRIBED_CLASS = 'described_class'.freeze
        MSG             = "Use `#{DESCRIBED_CLASS}` instead of `%s`".freeze

        def_node_matcher :common_instance_exec_closure?, <<-PATTERN
          (block (send (const nil {:Class :Module}) :new ...) ...)
        PATTERN

        def_node_matcher :rspec_block?,
                         RuboCop::RSpec::Language::ALL.block_pattern

        def_node_matcher :scope_changing_syntax?, '{def class module}'

        def on_block(node)
          describe, described_class, body = described_constant(node)
          return unless top_level_describe?(describe)

          find_constant_usage(body, described_class) do |match|
            add_offense(match, :expression, format(MSG, match.const_name))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, DESCRIBED_CLASS)
          end
        end

        private

        def find_constant_usage(node, described_class, &block)
          yield(node) if node.eql?(described_class)

          return unless node.instance_of?(Node)
          return if scope_change?(node) || node.const_type?

          node.children.each do |child|
            find_constant_usage(child, described_class, &block)
          end
        end

        def scope_change?(node)
          scope_changing_syntax?(node)          ||
            common_instance_exec_closure?(node) ||
            skippable_block?(node)
        end

        def skippable_block?(node)
          node.block_type? && !rspec_block?(node) && skip_blocks?
        end

        def skip_blocks?
          cop_config['SkipBlocks'].equal?(true)
        end
      end
    end
  end
end
