module RuboCop
  module Cop
    module RSpec
      # Prefer `contain_exactly` when matching an array literal.
      #
      # @example
      #   # bad
      #   it { is_expected.to match_array([content1, content2]) }
      #
      #   # good
      #   it { is_expected.to contain_exactly(content1, content2) }
      #
      #   # good
      #   it { is_expected.to match_array([content] + array) }
      class MatchArray < Cop
        MSG = 'Prefer `contain_exactly` when matching an array literal.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless method_name == :match_array

          return unless args.all? do |child_node|
            child_node.is_a?(Parser::AST::Node) && child_node.type == :array
          end
          add_offense node, :expression
        end

        def autocorrect(node)
          _receiver, _method_name, *args = *node

          lambda do |corrector|
            array_contents = args.flat_map(&:to_a)
            corrector.replace(
              node.source_range,
              "contain_exactly(#{array_contents.map(&:source).join(', ')})"
            )
          end
        end
      end
    end
  end
end
