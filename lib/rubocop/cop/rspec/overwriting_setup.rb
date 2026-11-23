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
      #
      class OverwritingSetup < Base
        MSG = '`%<name>s` is already defined.'

        # @!method setup?(node)
        def_node_matcher :setup?, <<~PATTERN
          {
            (block (send nil? {#Helpers.all #Subjects.all} ...) ...)
            (send nil? {#Helpers.all #Subjects.all} ... block_pass)
          }
        PATTERN

        # @!method first_argument_name(node)
        def_node_matcher :first_argument_name, '(send _ _ ({str sym} $_) ...)'

        # @!method unnamed_setup?(node)
        def_node_matcher :unnamed_setup?, '(send _ _ (block_pass ...)?)'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless example_group_with_body?(node)

          find_duplicates(node.body) do |duplicate, name|
            add_offense(
              duplicate,
              message: format(MSG, name: name)
            )
          end
        end

        private

        def find_duplicates(node)
          setup_expressions = Set.new
          node.each_child_node(:block, :send) do |child|
            next unless common_setup?(child)

            call = call_node(child)
            name = unnamed_setup?(call) ? :subject : first_argument_name(call)
            next unless name

            yield child, name.to_sym unless setup_expressions.add?(name.to_sym)
          end
        end

        def common_setup?(node)
          return false unless setup?(node)

          # Search only for setup with basic_literal arguments (e.g. :sym, :str)
          # or no arguments at all. A block-pass argument is ignored.
          call_node(node).arguments.all? do |argument|
            argument.basic_literal? || argument.block_pass_type?
          end
        end

        def call_node(node)
          node.send_type? ? node : node.send_node
        end
      end
    end
  end
end
