# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for setup scattered across multiple hooks in an example group.
      #
      # Unify `before` and `after` hooks when possible.
      # However, `around` hooks are allowed to be defined multiple times,
      # as unifying them would typically make the code harder to read.
      # Hooks defined in class methods are also ignored, as are hooks in
      # different branches of one conditional, which never both run. A
      # conditional inside an iterator can take every branch, so hooks in
      # its branches are still checked.
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
      #   # good
      #   describe Foo do
      #     around { |example| before1; example.call; after1 }
      #     around { |example| before2; example.call; after2 }
      #   end
      #
      #   # good
      #   describe Foo do
      #     before { setup1 }
      #     def self.setup
      #       before { setup2 }
      #     end
      #   end
      #
      #   # good
      #   describe Foo do
      #     if flag
      #       before { setup1 }
      #     else
      #       before { setup2 }
      #     end
      #   end
      #
      class ScatteredSetup < Base
        include FinalEndLocation
        include RangeHelp
        include RepeatedItems
        extend AutoCorrector

        MSG = 'Do not define multiple `%<hook_name>s` hooks in the same ' \
              'example group (also defined on %<lines>s).'

        LOOP_TYPES = %i[while until while_post until_post for].freeze

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless example_group?(node)

          repeated_hooks(node).each do |occurrences|
            occurrences.each do |occurrence|
              peers = co_occurring(occurrences, occurrence, node)
              next if peers.empty?

              # Anchor on the set's earliest hook, the same for every member,
              # so the corrections all merge in one direction.
              group = occurrences.select do |hook|
                hook.equal?(occurrence) || peers.include?(hook)
              end

              message = message(group, occurrence)
              add_offense(occurrence, message: message) do |corrector|
                autocorrect(corrector, group.first, occurrence)
              end
            end
          end
        end

        private

        def repeated_hooks(node) # rubocop:disable Metrics/CyclomaticComplexity
          hooks = RuboCop::RSpec::ExampleGroup.new(node).hooks
            .reject(&:inside_class_method?)
            .select { |hook| hook.knowable_scope? && hook.name != :around }

          find_repeated_groups(
            hooks,
            key_proc: ->(hook) { [hook.name, hook.scope, hook.metadata] }
          ).map { |hook_group| hook_group.map(&:to_node) }
        end

        # Hooks in different branches of one conditional never both run, so they
        # are not scattered setup. A hook outside the conditional does run
        # alongside one inside it, so only divergence at a shared conditional
        # counts.
        def co_occurring(occurrences, occurrence, group)
          occurrences.reject do |other|
            other.equal?(occurrence) ||
              mutually_exclusive?(occurrence, other, group)
          end
        end

        def mutually_exclusive?(node, other, group)
          branches = enclosing_branches(other, group)

          enclosing_branches(node, group).any? do |conditional, branch|
            branches.key?(conditional) && !branches[conditional].equal?(branch)
          end
        end

        # Maps each `if`/`case` between this node and its example group to the
        # branch the node sits in. A conditional inside a block or loop can be
        # evaluated more than once, taking each branch in turn, so only
        # conditionals outside every such block or loop are kept.
        def enclosing_branches(node, group)
          branches = {}
          child = node
          node.each_ancestor do |ancestor|
            break if ancestor.equal?(group)

            if ancestor.type?(:if, :case, :case_match)
              branches[ancestor] = child
            elsif ancestor.type?(:any_block, *LOOP_TYPES)
              branches.clear
            end
            child = ancestor
          end
          branches
        end

        def lines_msg(numbers)
          if numbers.size == 1
            "line #{numbers.first}"
          else
            "lines #{numbers.join(', ')}"
          end
        end

        def message(occurrences, occurrence)
          lines = occurrences.map(&:first_line)
          lines_except_current = lines - [occurrence.first_line]
          format(MSG, hook_name: occurrences.first.method_name,
                      lines: lines_msg(lines_except_current))
        end

        def autocorrect(corrector, first_occurrence, occurrence)
          return if first_occurrence == occurrence || !first_occurrence.body

          # Take heredocs into account
          body = occurrence.body&.source_range&.with(
            end_pos: final_end_location(occurrence).begin_pos
          )

          corrector.insert_after(first_occurrence.body,
                                 "\n#{body&.source}")
          corrector.remove(range_by_whole_lines(occurrence.source_range,
                                                include_final_newline: true))
        end
      end
    end
  end
end
