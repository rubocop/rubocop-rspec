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
      #     let!(:baz) { [] }
      #     let(:qux) { [] }
      #     let(:quux) { [] }
      #     subject(:quuz) { {} }
      #   end
      #
      #   describe MyClass do
      #     let(:foo) { [] }
      #     let(:bar) { [] }
      #     let!(:baz) { [] }
      #
      #     context 'when stuff' do
      #       let(:qux) { [] }
      #       let(:quux) { [] }
      #       subject(:quuz) { {} }
      #     end
      #   end
      #
      #   # good
      #   describe MyClass do
      #     let(:bar) { [] }
      #     let!(:baz) { [] }
      #     let(:qux) { [] }
      #     let(:quux) { [] }
      #     subject(:quuz) { {} }
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
      #       let(:qux) { [] }
      #       let(:quux) { [] }
      #       subject(:quuz) { {} }
      #     end
      #   end
      #
      # @example when disabling AllowSubject configuration
      #
      #   # rubocop.yml
      #   # RSpec/MultipleMemoizedHelpers:
      #   #   AllowSubject: true
      #
      #   # good
      #   describe MyClass do
      #     subject { {} }
      #     let(:foo) { [] }
      #     let(:bar) { [] }
      #     let!(:baz) { [] }
      #     let(:qux) { [] }
      #     let(:quux) { [] }
      #   end
      #
      # @example with Max configuration
      #
      #   # rubocop.yml
      #   # RSpec/MultipleMemoizedHelpers:
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
      class MultipleMemoizedHelpers < Base
        MSG = 'Example group has too many memoized helpers [%<count>d/%<max>d]'

        def on_block(node)
          return unless spec_group?(node)

          count = total_helpers(node)

          return if count <= max

          add_offense(node, message: format(MSG, count: count, max: max))
        end

        private

        def total_helpers(node)
          helpers(node) +
            node.each_ancestor(:block).map(&method(:helpers)).sum
        end

        def helpers(node)
          example_group = RuboCop::RSpec::ExampleGroup.new(node)
          if allow_subject?
            example_group.lets.count
          else
            example_group.lets.count + example_group.subjects.count
          end
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
