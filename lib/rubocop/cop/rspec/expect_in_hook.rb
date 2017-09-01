# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not use `expect` in hooks such as `before`.
      #
      # @example
      #   # bad
      #   before do
      #     expect(something).to eq 'foo'
      #   end
      #
      #   # bad
      #   after do
      #     expect_any_instance_of(Something).to receive(:foo)
      #   end
      #
      #   # good
      #   it do
      #     expect(something).to eq 'foo'
      #   end
      class ExpectInHook < Cop
        MSG = 'Do not use `%<expect>s` in `%<hook>s` hook'.freeze
        HOOKS = Hooks::ALL.node_pattern_union.freeze

        def_node_matcher :hook, <<-PATTERN
          (block (send _ $#{HOOKS} ...) _ $!nil)
        PATTERN

        def_node_search :expect, <<-PATTERN
          {
            #{Expectations::ALL.send_pattern}
            #{Expectations::ALL.block_pattern}
          }
        PATTERN

        def on_block(node)
          hook(node) do |hook_name, body|
            expect(body) do |expect|
              method = send_node(expect)
              add_offense(method, :selector,
                          message(method, hook_name))
            end
          end
        end

        private

        def message(expect, hook)
          format(MSG, expect: expect.method_name, hook: hook)
        end

        def send_node(node)
          return node if node.send_type?
          node.children.first
        end
      end
    end
  end
end
