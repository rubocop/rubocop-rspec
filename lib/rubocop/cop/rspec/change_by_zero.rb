# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Prefer negated matchers over `to change.by(0)`.
      #
      # In the case of composite expectations, cop suggest using the
      # negation matchers of `RSpec::Matchers#change`.
      #
      # By default the cop does not support autocorrect of
      # compound expectations, but if you set the
      # negated matcher for `change`, e.g. `not_change` with
      # the `NegatedMatcher` option, the cop will perform the autocorrection.
      #
      # @example NegatedMatcher: ~ (default)
      #   # bad
      #   expect { run }.to change(Foo, :bar).by(0)
      #   expect { run }.to change { Foo.bar }.by(0)
      #
      #   # bad - compound expectations (does not support autocorrection)
      #   expect { run }
      #     .to change(Foo, :bar).by(0)
      #     .and change(Foo, :baz).by(0)
      #   expect { run }
      #     .to change { Foo.bar }.by(0)
      #     .and change { Foo.baz }.by(0)
      #
      #   # good
      #   expect { run }.not_to change(Foo, :bar)
      #   expect { run }.not_to change { Foo.bar }
      #
      #   # good - compound expectations
      #   define_negated_matcher :not_change, :change
      #   expect { run }
      #     .to not_change(Foo, :bar)
      #     .and not_change(Foo, :baz)
      #   expect { run }
      #     .to not_change { Foo.bar }
      #     .and not_change { Foo.baz }
      #
      # @example NegatedMatcher: not_change
      #   # bad (support autocorrection to good case)
      #   expect { run }
      #     .to change(Foo, :bar).by(0)
      #     .and change(Foo, :baz).by(0)
      #   expect { run }
      #     .to change { Foo.bar }.by(0)
      #     .and change { Foo.baz }.by(0)
      #
      #   # good
      #   define_negated_matcher :not_change, :change
      #   expect { run }
      #     .to not_change(Foo, :bar)
      #     .and not_change(Foo, :baz)
      #   expect { run }
      #     .to not_change { Foo.bar }
      #     .and not_change { Foo.baz }
      #
      class ChangeByZero < Base
        extend AutoCorrector
        MSG = 'Prefer `not_to change` over `to change.by(0)`.'
        MSG_COMPOUND = 'Prefer %<preferred>s with compound expectations ' \
                       'over `change.by(0)`.'
        RESTRICT_ON_SEND = %i[change].freeze

        # @!method expect_change_with_arguments(node)
        def_node_matcher :expect_change_with_arguments, <<-PATTERN
          (send
            (send nil? :change ...) :by
            (int 0))
        PATTERN

        # @!method expect_change_with_block(node)
        def_node_matcher :expect_change_with_block, <<-PATTERN
          (send
            (block
              (send nil? :change)
              (args)
              (send (...) $_)) :by
            (int 0))
        PATTERN

        # @!method change_nodes(node)
        def_node_search :change_nodes, <<-PATTERN
          $(send nil? :change ...)
        PATTERN

        def on_send(node)
          expect_change_with_arguments(node.parent) do
            check_offense(node.parent)
          end

          expect_change_with_block(node.parent.parent) do
            check_offense(node.parent.parent)
          end
        end

        private

        def check_offense(node)
          expression = node.source_range
          if compound_expectations?(node)
            add_offense(expression, message: message_compound) do |corrector|
              autocorrect_compound(corrector, node)
            end
          else
            add_offense(expression) do |corrector|
              autocorrect(corrector, node)
            end
          end
        end

        def compound_expectations?(node)
          %i[and or & |].include?(node.parent.method_name)
        end

        def autocorrect(corrector, node)
          corrector.replace(node.parent.loc.selector, 'not_to')
          range = node.loc.dot.with(end_pos: node.source_range.end_pos)
          corrector.remove(range)
        end

        def autocorrect_compound(corrector, node)
          return unless negated_matcher

          change_nodes(node) do |change_node|
            corrector.replace(change_node.loc.selector, negated_matcher)
            range = node.loc.dot.with(end_pos: node.source_range.end_pos)
            corrector.remove(range)
          end
        end

        def negated_matcher
          cop_config['NegatedMatcher']
        end

        def message_compound
          format(MSG_COMPOUND, preferred: preferred_method)
        end

        def preferred_method
          negated_matcher ? "`#{negated_matcher}`" : 'negated matchers'
        end
      end
    end
  end
end
