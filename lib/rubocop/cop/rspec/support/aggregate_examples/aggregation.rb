module RuboCop
  module Cop
    module RSpec
      class AggregateExamples < Cop
        # @internal
        #   Aggregation helpers.
        module Aggregation
          private

          def drop_example(corrector, example)
            aggregated_range = range_by_whole_lines(example.source_range,
                                                    include_final_newline: true)
            corrector.remove(aggregated_range)
          end

          def range_for_replace(examples)
            range = range_by_whole_lines(examples.first.source_range,
                                         include_final_newline: true)
            next_range = range_by_whole_lines(examples[1].source_range)
            if adjacent?(range, next_range)
              range.resize(range.length + 1)
            else
              range
            end
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

          # Extracts and transforms the body, keeping proper indentation.
          def transform_body(node, base_indent)
            "#{base_indent}  #{new_body(node)}"
          end

          def new_body(node)
            node.body.source
          end
        end
      end
    end
  end
end
