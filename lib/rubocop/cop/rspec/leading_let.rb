# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Enforce that let definitions come before all other definitions.
      #
      # @example
      #   # bad
      #     subject { described_class.new(params) }
      #     let(:params) { blah }
      #
      #     before { do_something }
      #     let(:params) { blah }
      #
      #     it { expect_something }
      #     let(:params) { blah }
      #     it { expect_something_else }
      #
      #
      #   # good
      #     let(:params) { blah }
      #     subject { described_class.new(params) }
      #
      #   # good
      #     let(:params) { blah }
      #     before { do_something }
      #
      #   # good
      #     let(:params) { blah }
      #     it { expect_something }
      #     it { expect_something_else }
      #
      class LeadingLet < Base
        extend AutoCorrector

        MSG = 'Declare all `let` above any `%<offending>s` declarations.'

        def on_block(node)
          return unless let?(node)
          return if in_spec_block?(node)

          check_previous_nodes(node)
        end

        def check_previous_nodes(node)
          offending_node(node) do |offender|
            msg = format(MSG, offending: offender.method_name)
            add_offense(node, message: msg) do |corrector|
              autocorrect(corrector, node, offender)
            end
          end
        end

        private

        def offending_node(node)
          parent(node).each_child_node.find do |sibling|
            break if sibling.equal?(node)

            yield sibling if offending?(sibling)
          end
        end

        def parent(node)
          node.each_ancestor(:block).first.body
        end

        def autocorrect(corrector, node, sibling)
          RuboCop::RSpec::Corrector::MoveNode.new(
            node, corrector, processed_source
          ).move_before(sibling)
        end

        def offending?(node)
          subject?(node) ||
            hook?(node) ||
            example?(node) ||
            spec_group?(node) ||
            include?(node)
        end

        def in_spec_block?(node)
          node.each_ancestor(:block).any? do |ancestor|
            example?(ancestor)
          end
        end
      end
    end
  end
end
