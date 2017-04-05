# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for `subject` definitions that come after `let` definitions.
      #
      # @example
      #   # bad
      #   RSpec.describe User do
      #     let(:params) { blah }
      #     subject { described_class.new(params) }
      #
      #     it 'is valid' do
      #       expect(subject.valid?).to be(true)
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe User do
      #     subject { described_class.new(params) }
      #
      #     let(:params) { blah }
      #
      #     it 'is valid' do
      #       expect(subject.valid?).to be(true)
      #     end
      #   end
      class LeadingSubject < Cop
        MSG = 'Declare `subject` above any other `let` declarations.'.freeze

        def_node_matcher :subject?, '(block $(send nil :subject ...) args ...)'

        def on_block(node)
          return unless subject?(node) && !in_spec_block?(node)

          node.parent.each_child_node do |sibling|
            break if sibling.equal?(node)

            break add_offense(node, :expression) if let?(sibling)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            first_let = find_first_let(node)
            first_let_position = first_let.loc.expression
            indent = "\n" + ' ' * first_let.loc.column
            corrector.insert_before(first_let_position, node.source + indent)
            corrector.remove(node_range(node))
          end
        end

        private

        def let?(node)
          %i[let let!].include?(node.method_name)
        end

        def find_first_let(node)
          node.parent.children.find { |sibling| let?(sibling) }
        end

        def node_range(node)
          range = node.source_range
          range = range_with_surrounding_space(range, :left, false)
          range = range_with_surrounding_space(range, :right, true)
          range
        end

        def in_spec_block?(node)
          node.each_ancestor(:block).any? do |ancestor|
            Examples::ALL.include?(ancestor.method_name)
          end
        end
      end
    end
  end
end
