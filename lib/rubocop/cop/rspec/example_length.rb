# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # A long example is usually more difficult to understand. Consider
      # extracting out some behaviour, e.g. with a `let` block, or a helper
      # method.
      #
      # @example
      #   # bad
      #   it do
      #     service = described_class.new
      #     more_setup
      #     more_setup
      #     result = service.call
      #     expect(result).to be(true)
      #   end
      #
      #   # good
      #   it do
      #     service = described_class.new
      #     result = service.call
      #     expect(result).to be(true)
      #   end
      class ExampleLength < Cop
        include CodeLength
        EXAMPLE_BLOCKS = [:it, :specify].freeze

        def on_block(node)
          method, _args, _body = *node
          _receiver, method_name, _object = *method
          return unless EXAMPLE_BLOCKS.include?(method_name)

          length = code_length(node)

          return unless length > max_length
          add_offense(node, :expression, message(length))
        end

        private

        def code_length(node)
          lines = node.source.lines.to_a[1..-2]

          lines.count { |line| !irrelevant_line(line) }
        end

        def message(length)
          format('Example has too many lines. [%d/%d]', length, max_length)
        end
      end
    end
  end
end
