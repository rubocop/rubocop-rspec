# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for expectations on the same object that can be combined.
      #
      # @example
      #   # bad
      #   expect(obj.foo).to eq(bar)
      #   expect(obj.fu).to eq(bax)
      #   expect(obj.name).to eq(baz)
      #
      #   # good
      #   expect(obj).to have_attributes(
      #     foo: bar,
      #     fu: bax,
      #     name: baz
      #   )
      #
      class HaveAttributes < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Combine multiple expectations on the same object ' \
              'using `have_attributes`.'

        # Mapping of RSpec matchers to their have_attributes equivalents
        # nil means use the value directly (for eq)
        MATCHER_MAPPING = {
          eq: nil,
          be_an_instance_of: :an_instance_of,
          be_within: :a_value_within,
          contain_exactly: :a_collection_containing_exactly,
          end_with: :a_string_ending_with,
          start_with: :a_string_starting_with
        }.freeze

        # @!method expect_method_matcher?(node)
        def_node_matcher :expect_method_matcher?, <<~PATTERN
          (send
            (send nil? :expect
              (send $_ $_)
            )
            :to
            (send nil? $_ $_)
          )
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless example?(node)

          expectations = find_expectations(node)
          grouped = group_by_object(expectations)
          grouped.each_value do |group|
            next if group.size < 2

            flag_group(group)
          end
        end

        private

        def find_expectations(node)
          node.each_descendant(:send).filter_map do |send_node|
            expect_method_matcher?(send_node) do |obj, method, matcher, value|
              next if obj.nil? || !MATCHER_MAPPING.key?(matcher)

              {
                node: send_node,
                object: obj,
                method: method,
                matcher: matcher,
                value: value
              }
            end
          end
        end

        def group_by_object(expectations)
          expectations.each_with_object({}) do |exp, grouped|
            obj_key = exp[:object].source
            grouped[obj_key] ||= []
            grouped[obj_key] << exp
          end
        end

        def flag_group(group)
          # Sort by line number to maintain order
          sorted_group = group.sort_by { |exp| exp[:node].loc.line }

          # Flag all nodes in the group, but only correct once
          sorted_group.each_with_index do |exp, index|
            add_offense(exp[:node]) do |corrector|
              # Only correct on the first offense to avoid multiple corrections
              if index.zero?
                AttributesCorrector.new(sorted_group).call(corrector)
              end
            end
          end
        end

        # :nodoc:
        class AttributesCorrector
          include RangeHelp

          def initialize(group)
            # Sort nodes by position
            @sorted_nodes = group.sort_by do |exp|
              exp[:node].source_range.begin_pos
            end
          end

          def call(corrector)
            first_node = sorted_nodes.first[:node]

            # Replace the first node with the combined expectation
            replacement = build_replacement
            corrector.replace(first_node, replacement)

            # Remove the remaining nodes individually
            sorted_nodes[1..].each do |exp|
              node_range = range_by_whole_lines(
                exp[:node].source_range,
                include_final_newline: true,
                buffer: exp[:node].source_range.source_buffer
              )
              corrector.remove(node_range)
            end
          end

          private

          attr_reader :sorted_nodes

          def build_attributes
            sorted_nodes.map do |exp|
              method_name = exp[:method]
              matcher = exp[:matcher]
              value = exp[:value]

              transformed_value = transform_value(matcher, value)
              "#{method_name}: #{transformed_value}"
            end.join(",\n    ")
          end

          def transform_value(matcher, value)
            have_attributes_matcher = HaveAttributes::MATCHER_MAPPING[matcher]

            if have_attributes_matcher.nil?
              # For eq, use value directly
              # If value is keyword arguments (hash without braces), wrap in {}
              wrap_keyword_arguments(value)
            else
              # For other matchers, wrap value in the have_attributes matcher
              "#{have_attributes_matcher}(#{value.source})"
            end
          end

          def wrap_keyword_arguments(value)
            source = value.source
            if value.hash_type? && !source.strip.start_with?('{')
              "{ #{source} }"
            else
              source
            end
          end

          def build_replacement
            obj = sorted_nodes.first[:object]
            attributes = build_attributes
            <<~RUBY.chomp
              expect(#{obj.source}).to have_attributes(
                #{attributes}
              )
            RUBY
          end
        end
      end
    end
  end
end
