# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that tests use `described_class`.
      #
      # If the first argument of describe is a class, the class is exposed to
      # each example via described_class.
      #
      # This cop can be configured using the `EnforcedStyle` option
      #
      # @example `EnforcedStyle: described_class`
      #   # bad
      #   describe MyClass do
      #     subject { MyClass.do_something }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     subject { described_class.do_something }
      #   end
      #
      # @example `EnforcedStyle: explicit`
      #   # bad
      #   describe MyClass do
      #     subject { described_class.do_something }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     subject { MyClass.do_something }
      #   end
      #
      class DescribedClass < Cop
        include RuboCop::RSpec::TopLevelDescribe
        include ConfigurableEnforcedStyle

        DESCRIBED_CLASS = 'described_class'.freeze
        MSG             = 'Use `%s` instead of `%s`.'.freeze

        def_node_matcher :common_instance_exec_closure?, <<-PATTERN
          (block (send (const nil {:Class :Module}) :new ...) ...)
        PATTERN

        def_node_matcher :rspec_block?,
                         RuboCop::RSpec::Language::ALL.block_pattern

        def_node_matcher :scope_changing_syntax?, '{def class module}'

        def on_block(node)
          describe, described_class, body = described_constant(node)
          return unless top_level_describe?(describe)

          # in case we explicit style is used, this cop needs to remember what's
          # being described, so to replace described_class with the constant
          @described_class = described_class

          find_usage(body) do |match|
            add_offense(match, :expression, message(match.const_name))
          end
        end

        def autocorrect(node)
          replacement = if style == :described_class
                          DESCRIBED_CLASS
                        else
                          @described_class.const_name
                        end
          lambda do |corrector|
            corrector.replace(node.loc.expression, replacement)
          end
        end

        private

        def find_usage(node, &block)
          yield(node) if offensive?(node)

          return unless node.is_a?(Parser::AST::Node)
          return if scope_change?(node) || node.const_type?

          node.children.each do |child|
            find_usage(child, &block)
          end
        end

        def message(offense)
          if style == :described_class
            format(MSG, DESCRIBED_CLASS, offense)
          else
            format(MSG, @described_class.const_name, DESCRIBED_CLASS)
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

        def offensive?(node)
          if style == :described_class
            node.eql?(@described_class)
          else
            _receiver, method_name, *_args = *node
            method_name == :described_class
          end
        end
      end
    end
  end
end
