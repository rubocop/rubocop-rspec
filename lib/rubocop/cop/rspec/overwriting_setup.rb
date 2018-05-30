# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if there is a let/subject that overwrites an existing one.
      #
      # @example
      #   # bad
      #   let(:foo) { bar }
      #   let(:foo) { baz }
      #
      #   subject(:foo) { bar }
      #   let(:foo) { baz }
      #
      #   let(:foo) { bar }
      #   let!(:foo) { baz }
      #
      #   # good
      #   subject(:test) { something }
      #   let(:foo) { bar }
      #   let(:baz) { baz }
      #   let!(:other) { other }
      class OverwritingSetup < Cop
        include RuboCop::RSpec::Util

        MSG = '`%<name>s` is already defined.'.freeze

        def_node_matcher :setup?, (Helpers::ALL + Subject::ALL).block_pattern

        def on_block(node)
          return unless example_group_with_body?(node)

          find_duplicates(node.body) do |duplicate, name|
            add_offense(
              duplicate,
              location: :expression,
              message: format(MSG, name: name)
            )
          end
        end

        private

        def find_duplicates(node)
          setup_expressions = Set.new
          node.each_child_node do |child|
            next unless setup?(child)

            name = if child.send_node.arguments?
                     child.send_node.first_argument.value
                   else
                     :subject
                   end

            yield child, name unless setup_expressions.add?(name)
          end
        end
      end
    end
  end
end
