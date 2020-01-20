# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if example groups contain too many `let` and `subject` calls.
      #
      # This cop is configurable using the `Max` option and the `AllowSubject`
      # which will configure the cop to only register offenses on calls to
      # `let` and not calls to `subject`.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     let(:foo) { [] }
      #     let(:bar) { [] }
      #     let!(:booger) { [] }
      #     subject { {} }
      #     subject(:wat) { {} }
      #     subject!(:boo) { {} }
      #   end
      #
      #   describe MyClass do
      #     let(:foo) { [] }
      #     let(:bar) { [] }
      #
      #     context 'when stuff' do
      #       let!(:booger) { [] }
      #       subject { {} }
      #       subject(:wat) { {} }
      #       subject!(:boo) { {} }
      #     end
      #   end
      #
      #   # good
      #   describe MyClass do
      #     let(:foo) { [] }
      #     let!(:booger) { [] }
      #     subject { {} }
      #     subject(:wat) { {} }
      #     subject!(:boo) { {} }
      #   end
      #
      #   describe MyClass do
      #     context 'when stuff' do
      #       let(:foo) { [] }
      #       let(:bar) { [] }
      #       let!(:booger) { [] }
      #     end
      #
      #     context 'when other stuff' do
      #       subject { {} }
      #       subject(:wat) { {} }
      #       subject!(:boo) { {} }
      #     end
      #   end
      #
      # @example with AllowSubject configuration
      #
      #   # rubocop.yml
      #   # RSpec/MemoizedHelpersInExampleGroup:
      #   #   AllowSubject: true
      #
      #   # bad
      #   describe MyClass do
      #     let(:foo) { [] }
      #     let(:bar) { [] }
      #     let!(:booger) { [] }
      #     let(:subject) { {} }
      #     let(:wat) { {} }
      #     let!(:boo) { {} }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     let(:foo) { [] }
      #     let(:bar) { [] }
      #     let!(:booger) { [] }
      #     subject { {} }
      #     subject(:wat) { {} }
      #     subject!(:boo) { {} }
      #   end
      #
      # @example with Max configuration
      #
      #   # rubocop.yml
      #   # RSpec/MemoizedHelpersInExampleGroup:
      #   #   Max: 0
      #
      #   # bad
      #   describe MyClass do
      #     let(:foo) { [] }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     def foo; []; end
      #   end
      #
      class MemoizedHelpersInExampleGroup < Cop
        MSG = 'Example has too many memoized helpers [%<count>d/%<max>d]'

        def on_block(node)
          return unless spec_group?(node)

          count = count_helpers(node)

          node.each_ancestor(:block) do |ancestor|
            count += count_helpers(ancestor)
          end

          return if count <= max

          add_offense(node, message: format(MSG, count: count, max: max))
        end

        private

        def count_helpers(node)
          example_group = RuboCop::RSpec::ExampleGroup.new(node)
          count = example_group.lets.count
          count += example_group.subjects.count unless allow_subject?
          count
        end

        def max
          cop_config['Max']
        end

        def allow_subject?
          cop_config['AllowSubject']
        end
      end
    end
  end
end
