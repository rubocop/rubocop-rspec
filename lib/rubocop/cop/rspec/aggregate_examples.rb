# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if example groups contain more than one aggregateable example.
      #
      # @see https://github.com/rubocop-hq/rspec-style-guide#expectations-per-example
      #
      # This cop is primarily for reducing the cost of repeated expensive
      # context initialization.
      #
      # @example
      #
      #   # bad
      #   describe do
      #     specify do
      #       expect(number).to be_positive
      #       expect(number).to be_odd
      #     end
      #
      #     it { is_expected.to be_prime }
      #   end
      #
      #   # good
      #   describe do
      #     specify do
      #       expect(number).to be_positive
      #       expect(number).to be_odd
      #       is_expected.to be_prime
      #     end
      #   end
      #
      #   # fair - subject has side effects
      #   describe do
      #     specify do
      #       expect(multiply_by(2)).to be_multiple_of(2)
      #     end
      #
      #     specify do
      #       expect(multiply_by(3)).to be_multiple_of(3)
      #     end
      #   end
      #
      # Block expectation syntax is deliberately not supported due to:
      #
      # 1. `subject { -> { ... } }` syntax being hard to detect, e.g. the
      #    following looks like an example with non-block syntax, but it might
      #    be depending on how the subject is defined:
      #
      #        it { is_expected.to do_something }
      #
      #    If the subject is defined in a `shared_context`, it's impossible to
      #    detect that at all.
      #
      # 2. Aggregation should use composition with an `.and`. Also, aggregation
      #    of the `not_to` expectations is barely possible when a matcher
      #    doesn't provide a negated variant.
      #
      # 3. Aggregation of block syntax with non-block syntax should be in a
      #    specific order.
      #
      #
      # The examples containing matchers that leave subject in modified state
      # will fail when not supposed to or come with a risk of not failing when
      # expected to fail if aggregated. One example is
      # `validate_presence_of :comment` as it leaves an empty comment after
      # itself on the subject making it invalid and the subsequent expectation
      # to fail. Examples with those matchers are not supposed to be aggregated.
      #
      # @example MatchersWithSideEffects
      #
      #   # .rubocop.yml
      #   # RSpec/AggregateExamples:
      #   #   MatchersWithSideEffects:
      #   #   - allow_value
      #   #   - allow_values
      #   #   - validate_presence_of
      #
      #   # bad, but is not automatically correctable
      #   describe do
      #     it { is_expected.to validate_presence_of(:comment) }
      #     it { is_expected.to be_valid }
      #   end
      #
      #
      # RSpec [comes with an `aggregate_failures` helper](https://relishapp.com/rspec/rspec-expectations/docs/aggregating-failures)
      # not to fail the example on first unmet expectation that might come
      # handy with aggregated examples.
      # It can be [used in metadata form](https://relishapp.com/rspec/rspec-core/docs/expectation-framework-integration/aggregating-failures#use-%60:aggregate-failures%60-metadata),
      # or [enabled globally](https://relishapp.com/rspec/rspec-core/docs/expectation-framework-integration/aggregating-failures#enable-failure-aggregation-globally-using-%60define-derived-metadata%60).
      #
      # @example Globally enable `aggregate_failures`
      #
      #   # spec/spec_helper.rb
      #   config.define_derived_metadata do |metadata|
      #     unless metadata.key?(:aggregate_failures)
      #       metadata[:aggregate_failures] = true
      #     end
      #   end
      #
      # To match the style being used in the spec suite, AggregateExamples
      # can be configured to add metadata to the example or not. The option
      # not to add metadata can be also used when it's not desired to make
      # expectations after previously failed ones commonly known as fail-fast.
      #
      # @example AddAggregateFailuresMetadata: false (default)
      #
      #   specify do
      #     expect(number).to be_positive
      #     expect(number).to be_odd
      #   end
      #
      # @example AddAggregateFailuresMetadata: true
      #
      #   specify(:aggregate_failures) do
      #     expect(number).to be_positive
      #     expect(number).to be_odd
      #   end
      #
      class AggregateExamples < Cop # rubocop:disable Metrics/ClassLength
        include RangeHelp

        MSG = 'Aggregate with the example above.'.freeze
        MSG_FOR_EXPECTATIONS_WITH_SIDE_EFFECTS =
          "#{MSG} IMPORTANT! Pay attention to the expectation order, some " \
          'of the matchers have side effects.'.freeze

        def on_block(node)
          example_group_with_several_examples(node) do |all_examples|
            example_cluster(all_examples).each do |_, examples|
              message = message_for(examples)
              add_offense(examples[1], location: :expression, message: message)
            end
          end
        end

        def autocorrect(example_node)
          examples_in_group = example_node.parent.each_child_node(:block)
            .select { |example| example_for_autocorrect?(example) }

          lambda do |corrector|
            example_cluster(examples_in_group).each do |metadata, examples|
              range = range_for_replace(examples)
              replacement = aggregated_example(examples, metadata)
              corrector.replace(range, replacement)
              examples[1..-1].map { |example| drop_example(corrector, example) }
            end
          end
        end

        private

        def_node_matcher :example_group_with_several_examples, <<-PATTERN
          (block
            #{ExampleGroups::ALL.send_pattern}
            _
            (begin $...)
          )
        PATTERN

        def example_cluster(all_examples)
          all_examples
            .select { |example| example_with_expectations_only?(example) }
            .group_by { |example| metadata_without_aggregate_failures(example) }
            .reject { |_, examples| examples.count < 2 }
        end

        def range_for_replace(examples)
          range = range_by_whole_lines(examples.first.source_range,
                                       include_final_newline: true)
          next_range = range_by_whole_lines(examples[1].source_range)
          range = range.resize(range.length + 1) if adjacent?(range, next_range)
          range
        end

        def adjacent?(range, another_range)
          range.end_pos + 1 == another_range.begin_pos
        end

        def aggregated_example(examples, metadata)
          base_indent = ' ' * examples.first.source_range.column
          metadata = metadata_for_aggregated_example(metadata)
          [
            "#{base_indent}specify#{metadata} do",
            *examples.map { |example| transform_body(example, base_indent) },
            "#{base_indent}end\n"
          ].join("\n")
        end

        def metadata_for_aggregated_example(metadata)
          metadata_to_add = metadata.compact.map(&:source)
          if add_aggregate_failures_metadata?
            metadata_to_add.unshift(':aggregate_failures')
          end
          if metadata_to_add.any?
            "(#{metadata_to_add.join(', ')})"
          else
            ''
          end
        end

        def add_aggregate_failures_metadata?
          cop_config.fetch('AddAggregateFailuresMetadata', false)
        end

        def drop_example(corrector, example)
          aggregated_range = range_by_whole_lines(example.source_range,
                                                  include_final_newline: true)
          corrector.remove(aggregated_range)
        end

        # Extracts and transforms the body.
        # `its(:something) { is_expected.to ... }` is a special case, since
        # it's impossible to aggregate its body as is,
        # it needs to be converted to `expect(subject.something).to ...`
        # Additionally indents the example code properly.
        def transform_body(node, base_indent)
          new_body = if node.method_name == :its
                       transform_its(node.body, node.send_node.arguments)
                     else
                       node.body.source
                     end
          "#{base_indent}  #{new_body}"
        end

        def transform_its(body, arguments)
          property = arguments.first.value
          body.source.gsub(/is_expected|are_expected/,
                           "expect(subject.#{property})")
        end

        def message_for(examples)
          if examples.any? { |example| example_with_side_effects?(example) }
            MSG_FOR_EXPECTATIONS_WITH_SIDE_EFFECTS
          else
            MSG
          end
        end

        def example_method?(method_name)
          %i[it specify example scenario].include?(method_name)
        end

        def_node_matcher :example_with_expectations_only?, <<-PATTERN
          (block #example_block? _
            { #single_expectation? #all_expectations? }
          )
        PATTERN

        def metadata_without_aggregate_failures(example)
          # Parameters to `its` are not metadata.
          return [] if example.send_node.method_name == :its

          metadata = example.send_node.arguments || []

          symbols = metadata_symbols_without_aggregate_failures(metadata)
          pairs = metadata_pairs_without_aggegate_failures(metadata)
          symbols << Object.new if aggregate_failures_disabled(pairs)

          [*symbols, pairs].flatten.compact
        end

        def metadata_symbols_without_aggregate_failures(metadata)
          metadata
            .select(&:sym_type?)
            .reject { |item| item.value == :aggregate_failures }
        end

        def metadata_pairs_without_aggegate_failures(metadata)
          map = metadata.find(&:hash_type?)
          pairs = map && map.pairs || []
          pairs.reject do |pair|
            pair.key.value == :aggregate_failures && pair.value.true_type?
          end
        end

        def aggregate_failures_disabled(pairs)
          pairs.find { |pair| pair.key.value == :aggregate_failures }
        end

        # Matchers examples with:
        # - expectation statements exclusively
        # - no metadata (e.g. `freeze: :today`)
        # - no title (e.g. `it('jumps over the lazy dog')`)
        # and skips `its` with an array argument due to ambiguous conversion
        #   e.g. the SUT can be an object (`expect(object.property)`)
        #   or a hash/array (`expect(hash['property'])`)
        # and also skips matchers with known side-effects
        def_node_matcher :example_for_autocorrect?, <<-PATTERN
          [
            #example_with_expectations_only?
            !#example_has_title?
            !#its_with_array_argument?
            !#contains_heredoc?
            !#example_with_side_effects?
          ]
        PATTERN

        # Matches the example with a title (e.g. `it('is valid')`)
        def_node_matcher :example_has_title?, <<-PATTERN
          (block
            (send nil? #example_method? str ...)
            ...
          )
        PATTERN

        def_node_matcher :its_with_array_argument?, <<-PATTERN
          (block (send nil? :its array) ...)
        PATTERN

        # Searches for HEREDOC in examples. It can be tricky to aggregate,
        # especially when interleaved with parenthesis or curly braces.
        def contains_heredoc?(node)
          node.each_descendant(:str, :xstr, :dstr).any?(&:heredoc?)
        end

        def_node_matcher :subject_with_no_args?, <<-PATTERN
          (send _ _)
        PATTERN

        def_node_matcher :expectation?, <<-PATTERN
          {
            (send nil? :is_expected)
            (send nil? :expect #subject_with_no_args?)
          }
        PATTERN

        def matcher_with_side_effects_names
          cop_config.fetch('MatchersWithSideEffects', [])
            .map(&:to_sym)
        end

        def matcher_with_side_effects_name?(matcher_name)
          matcher_with_side_effects_names.include?(matcher_name)
        end

        # Matches the matcher with side effects
        def_node_matcher :matcher_with_side_effects?, <<-PATTERN
          (send nil? { #matcher_with_side_effects_name? } ...)
        PATTERN

        # Matches the expectation with matcher with side effects
        def_node_matcher :expectation_with_side_effects?, <<-PATTERN
          (send #expectation? #{Runners::ALL.node_pattern_union} #matcher_with_side_effects?)
        PATTERN

        # Matches the example with matcher with side effects
        def_node_matcher :example_with_side_effects?, <<-PATTERN
          (block #example_block? _ #expectation_with_side_effects?)
        PATTERN

        def all_expectations?(node)
          return unless node && node.begin_type?

          node.children.all? { |statement| single_expectation?(statement) }
        end

        def_node_matcher :single_expectation?, <<-PATTERN
          (send #expectation? #{Runners::ALL.node_pattern_union} _)
        PATTERN

        # Matches example block
        def_node_matcher :example_block?, <<-PATTERN
          (send nil? #{Examples::EXAMPLES.node_pattern_union} ...)
        PATTERN

        def_node_matcher :example_node?, <<-PATTERN
          (block #example_block? ...)
        PATTERN
      end
    end
  end
end
