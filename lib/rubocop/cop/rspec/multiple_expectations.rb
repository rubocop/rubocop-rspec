# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if examples contain too many `expect` calls.
      #
      # @see http://betterspecs.org/#single Single expectation test
      #
      # This cop is configurable using the `Max` option
      # and works with `--auto-gen-config`.
      #
      # @example
      #   # bad
      #   describe UserCreator do
      #     it 'builds a user' do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      #   # good
      #   describe UserCreator do
      #     it 'sets the users name' do
      #       expect(user.name).to eq("John")
      #     end
      #
      #     it 'sets the users age' do
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example `aggregate_failures: true` (default)
      #   # good - the cop ignores when RSpec aggregates failures
      #   describe UserCreator do
      #     it 'builds a user', :aggregate_failures do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example `aggregate_failures: false`
      #   # Detected as an offense
      #   describe UserCreator do
      #     it 'builds a user', aggregate_failures: false do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example `Max: 1` (default)
      #   # bad
      #   describe UserCreator do
      #     it 'builds a user' do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      # @example `Max: 2`
      #   # good
      #   describe UserCreator do
      #     it 'builds a user' do
      #       expect(user.name).to eq("John")
      #       expect(user.age).to eq(22)
      #     end
      #   end
      #
      class MultipleExpectations < Base # rubocop:disable Metrics/ClassLength
        extend AutoCorrector

        MSG = 'Example has too many expectations [%<total>d/%<max>d].'

        ANYTHING = ->(_node) { true }
        TRUE_NODE = lambda(&:true_type?)

        exclude_limit 'Max'

        # @!method aggregate_failures?(node)
        def_node_matcher :aggregate_failures?, <<~PATTERN
          (send _ _ <{ (sym :aggregate_failures) (hash <(pair (sym :aggregate_failures) _) ...>) } ...>)
        PATTERN
        # @!method metadata_present?(node)
        def_node_matcher :metadata_present?, '(send _ _ <{sym hash} ...>)'

        # @!method aggregate_failures_definition?(node)
        def_node_matcher :aggregate_failures_definition?, <<~PATTERN
          (block {
              (send _ _ <(sym :aggregate_failures) ...>)
              (send _ _ ... (hash <(pair (sym :aggregate_failures) %1) ...>))
            } ...)
        PATTERN

        # @!method expect?(node)
        def_node_matcher :expect?, '(send nil? #Expectations.all ...)'

        # @!method aggregate_failures_block?(node)
        def_node_matcher :aggregate_failures_block?, <<~PATTERN
          (block (send nil? :aggregate_failures ...) ...)
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless example?(node)

          return if example_with_aggregate_failures?(node)

          expectations_count = to_enum(:find_expectation, node).count

          return if expectations_count <= max_expectations

          self.max = expectations_count

          flag_example(node, expectation_count: expectations_count)
        end

        private

        def example_with_aggregate_failures?(example_node)
          node_with_aggregate_failures = find_aggregate_failures(example_node)
          return false unless node_with_aggregate_failures

          aggregate_failures_definition?(node_with_aggregate_failures,
                                         TRUE_NODE)
        end

        def find_aggregate_failures(example_node)
          example_node.send_node.each_ancestor(:block).find do |block_node|
            aggregate_failures_definition?(block_node, ANYTHING)
          end
        end

        def find_expectation(node, &block)
          yield if expect?(node) || aggregate_failures_block?(node)

          # do not search inside of aggregate_failures block
          return if aggregate_failures_block?(node)

          node.each_child_node do |child|
            find_expectation(child, &block)
          end
        end

        def flag_example(node, expectation_count:)
          add_offense(
            node.send_node,
            message: format(
              MSG,
              total: expectation_count,
              max: max_expectations
            )
          ) do |corrector|
            autocorrect_metadata(corrector, node.send_node)
          end
        end

        def max_expectations
          Integer(cop_config.fetch('Max', 1))
        end

        def autocorrect_metadata(corrector, node)
          return if aggregate_failures?(node)

          if metadata_present?(node)
            add_hash_metadata(corrector, node)
          else
            add_symbol_metadata(corrector, node)
          end
        end

        def add_symbol_metadata(corrector, node)
          if node.arguments.empty?
            # Handle cases like `it { ... }` vs `it(...) { ... }`
            loc, str = if node.loc.begin
                         [node.loc.begin, ':aggregate_failures']
                       else
                         [node.loc.selector, '(:aggregate_failures)']
                       end
            corrector.insert_after(loc, str)
          else
            corrector.insert_after(node.last_argument,
                                   ', :aggregate_failures')
          end
        end

        def add_hash_metadata(corrector, node)
          if (hash_node = node.arguments.reverse.find(&:hash_type?))
            if hash_node.pairs.empty?
              corrector.insert_before(hash_node.loc.end,
                                      ' aggregate_failures: true ')
            else
              corrector.insert_after(hash_node.pairs.last,
                                     ', aggregate_failures: true')
            end
          else
            corrector.insert_after(node.last_argument,
                                   ', aggregate_failures: true')
          end
        end
      end
    end
  end
end
