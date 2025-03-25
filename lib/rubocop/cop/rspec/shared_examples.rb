# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent style for shared examples.
      #
      # Enforces either `string` or `symbol` for shared example names. This
      # can be configured using the `EnforcedStyle` option.
      #
      # Can also be used to enforce the preferred method name to use for
      # defining and including shared examples and contexts. Each can get a
      # different value.
      #
      # [source,yaml]
      # ----
      # RSpec/SharedExamples:
      #   PreferredExamplesMethod: shared_examples
      #   PreferredContextMethod: shared_context
      #   PreferredIncludeExamplesMethod: it_behaves_like
      #   PreferredIncludeContextMethod: include_context
      # ----
      #
      # By default, no preference is set, so any methods provided in the
      # `Language/SharedGroups` and `Language/Includes` configuration are
      # allowed.
      #
      # @example `EnforcedStyle: string` (default)
      #   # bad
      #   it_behaves_like :foo_bar_baz
      #   it_should_behave_like :foo_bar_baz
      #   shared_examples :foo_bar_baz
      #   shared_examples_for :foo_bar_baz
      #   include_examples :foo_bar_baz
      #
      #   # good
      #   it_behaves_like 'foo bar baz'
      #   it_should_behave_like 'foo bar baz'
      #   shared_examples 'foo bar baz'
      #   shared_examples_for 'foo bar baz'
      #   include_examples 'foo bar baz'
      #
      # @example `EnforcedStyle: symbol`
      #   # bad
      #   it_behaves_like 'foo bar baz'
      #   it_should_behave_like 'foo bar baz'
      #   shared_examples 'foo bar baz'
      #   shared_examples_for 'foo bar baz'
      #   include_examples 'foo bar baz'
      #
      #   # good
      #   it_behaves_like :foo_bar_baz
      #   it_should_behave_like :foo_bar_baz
      #   shared_examples :foo_bar_baz
      #   shared_examples_for :foo_bar_baz
      #   include_examples :foo_bar_baz
      #
      class SharedExamples < Base
        extend AutoCorrector
        include ConfigurableEnforcedStyle

        MSG_INCORRECT_METHOD = 'Prefer `%<prefer>s` over `%<current>s`.'

        # @!method shared_examples(node)
        def_node_matcher :shared_examples, <<~PATTERN
          {
            (send #rspec? #SharedGroups.all $_ ...)
            (send nil? #Includes.all $_ ...)
          }
        PATTERN

        def on_send(node)
          shared_examples(node) do |ast_node|
            register_method_name_offense(node)

            next unless offense?(ast_node)

            checker = new_checker(ast_node)
            add_offense(ast_node, message: checker.message) do |corrector|
              corrector.replace(ast_node, checker.preferred_style)
            end
          end
        end

        private

        def offense?(ast_node)
          if style == :symbol
            ast_node.str_type?
          else # string
            ast_node.sym_type?
          end
        end

        def register_method_name_offense(node)
          preferred_method_name = preferred_method_name(node.method_name)
          return unless preferred_method_name
          return if node.method?(preferred_method_name)

          selector = node.loc.selector
          message = format(
            MSG_INCORRECT_METHOD,
            prefer: preferred_method_name,
            current: node.method_name
          )

          add_offense(selector, message: message) do |corrector|
            corrector.replace(selector, preferred_method_name)
          end
        end

        def preferred_method_name(method_name)
          if SharedGroups.examples(method_name)
            cop_config['PreferredExamplesMethod']
          elsif SharedGroups.context(method_name)
            cop_config['PreferredContextMethod']
          elsif Includes.examples(method_name)
            cop_config['PreferredIncludeExamplesMethod']
          elsif Includes.context(method_name)
            # :nocov: - simplecov is not detecting the coverage of this branch!
            cop_config['PreferredIncludeContextMethod']
            # :nocov:
          end
        end

        def new_checker(ast_node)
          if style == :symbol
            SymbolChecker.new(ast_node)
          else # string
            StringChecker.new(ast_node)
          end
        end

        # :nodoc:
        class SymbolChecker
          MSG = 'Prefer %<prefer>s over `%<current>s` ' \
                'to symbolize shared examples.'

          attr_reader :node

          def initialize(node)
            @node = node
          end

          def message
            format(MSG, prefer: preferred_style, current: node.value.inspect)
          end

          def preferred_style
            ":#{node.value.to_s.downcase.tr(' ', '_')}"
          end
        end

        # :nodoc:
        class StringChecker
          MSG = 'Prefer %<prefer>s over `%<current>s` ' \
                'to titleize shared examples.'

          attr_reader :node

          def initialize(node)
            @node = node
          end

          def message
            format(MSG, prefer: preferred_style, current: node.value.inspect)
          end

          def preferred_style
            "'#{node.value.to_s.tr('_', ' ')}'"
          end
        end
      end
    end
  end
end
