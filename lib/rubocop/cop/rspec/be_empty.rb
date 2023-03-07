# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Prefer using `be_empty` when checking for an empty array.
      #
      # @example
      #   # bad
      #   expect(array.empty?).to be true
      #   expect(array.empty?).to be_truthy
      #   expect(array.size).to eq(0)
      #   expect(array.length).to eq(0)
      #   expect(array.count).to eq(0)
      #   expect(array).to eql([])
      #   expect(array).to contain_exactly
      #   expect(array).to match_array([])
      #
      #   # good
      #   expect(array).to be_empty
      #
      class BeEmpty < Base
        extend AutoCorrector

        MSG = 'Use `be_empty` matchers for checking an empty array.'
        RESTRICT_ON_SEND =
          %i[be be_truthy eq eql contain_exactly match_array].freeze

        # @!method expect_array_empty_true?(node)
        def_node_matcher :expect_array_empty_true?, <<~PATTERN
          (send
            (send nil? :expect $(send _ :empty?))
            #Runners.all
            ${(send nil? :be true) (send nil? :be_truthy)}
          )
        PATTERN

        # @!method expect_array_size_zero?(node)
        def_node_matcher :expect_array_size_zero?, <<~PATTERN
          (send
            (send nil? :expect $(send _ {:size :length :count}))
            #Runners.all
            $(send nil? {:eq :eql} (int 0))
          )
        PATTERN

        # @!method expect_array_matcher?(node)
        def_node_matcher :expect_array_matcher?, <<~PATTERN
          (send
            (send nil? :expect _)
            #Runners.all
            ${
              (send nil? {:eq :eql :match_array} (array))
              (send nil? :contain_exactly)
            }
          )
        PATTERN

        def on_send(node)
          expect_array_empty_true?(node.parent) do |actual, expect|
            register_offense(actual, expect)
          end
          expect_array_size_zero?(node.parent) do |actual, expect|
            register_offense(actual, expect)
          end
          expect_array_matcher?(node.parent) do |expect|
            register_offense(nil, expect)
          end
        end

        private

        def register_offense(actual, expect)
          add_offense(expect) do |corrector|
            corrector.replace(actual, actual.receiver.source) if actual
            corrector.replace(expect, 'be_empty')
          end
        end
      end
    end
  end
end
