# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for setup scattered across multiple hooks in an example group.
      #
      # Unify `before`, `after`, and `around` hooks when possible.
      #
      # Autocorrection is not supported when `around` is used because it can
      # be difficult to unify them.
      #
      # @safety
      #   This cop's autocorrection is unsafe because it could change the order
      #   of processing if there is another hook between them.
      #   (e.g. `let!` between `before`s)
      #
      # @example
      #   # bad
      #   describe Foo do
      #     before { setup1 }
      #     before { setup2 }
      #   end
      #
      #   # good
      #   describe Foo do
      #     before do
      #       setup1
      #       setup2
      #     end
      #   end
      #
      class ScatteredSetup < Base
        extend AutoCorrector

        include RangeHelp

        MSG = 'Do not define multiple `%<hook_name>s` hooks in the same ' \
              'example group (also defined on line %<line>s).'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless hook?(node)

          same_hook = find_same_hook(node)
          return unless same_hook

          add_offense(node, message: format_message(same_hook)) do |corrector|
            next if node.method?(:around)

            merge_hooks(corrector, same_hook, node)
          end
        end

        private

        def find_same_hook(node)
          return unless hook_knowable_scope(node)

          node.left_siblings.find do |sibling|
            hook?(sibling) &&
              sibling.method?(node.method_name) &&
              hook_knowable_scope(node) &&
              hook_scope(sibling) == hook_scope(node) &&
              hook_metadata(sibling) == hook_metadata(node)
          end
        end

        def format_message(node)
          format(
            MSG,
            hook_name: node.method_name,
            line: node.location.line
          )
        end

        def hook_knowable_scope(node)
          RuboCop::RSpec::Hook.new(node).knowable_scope?
        end

        def hook_metadata(node)
          RuboCop::RSpec::Hook.new(node).metadata
        end

        def hook_scope(node)
          RuboCop::RSpec::Hook.new(node).scope
        end

        def merge_hooks(corrector, node1, node2)
          corrector.insert_after(
            node1.body || node1.location.begin,
            "\n\n#{node2.body.source}"
          )
          corrector.remove(
            range_by_whole_lines(
              node2.location.expression,
              include_final_newline: true
            )
          )
        end
      end
    end
  end
end
