# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for `subject` definitions that come after `let` definitions
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
        include RuboCop::RSpec::SpecOnly, RuboCop::RSpec::Language

        MSG = 'Declare `subject` above any other `let` declarations'.freeze

        def_node_matcher :subject?, '(block $(send nil :subject ...) args ...)'

        def on_block(node)
          return unless subject?(node) && !in_spec_block?(node)

          node.parent.each_child_node do |sibling|
            break if sibling.equal?(node)

            if sibling.method_name.equal?(:let)
              break add_offense(node, :expression)
            end
          end
        end

        private

        def in_spec_block?(node)
          node.each_ancestor(:block).any? do |ancestor|
            Examples::ALL.include?(ancestor.method_name)
          end
        end
      end
    end
  end
end
