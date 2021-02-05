# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Matchers used in expectations should not be defined in memoized helpers.
      #
      # @example
      #   # bad - plain data
      #   let(:expected_value) { {a: 1, b: 2, c: 3} }
      #
      #   it 'returns a proper hash' do
      #     expect(parser.parse).to eq expected_value
      #   end
      #
      #   # bad - compound matcher defined in a memoized helper
      #   let(:expected) { be_positive.and be_rational }
      #
      #   it 'sums up to a positive rational' do
      #     expect(calculator.sum).to expected
      #   end
      #
      #   # good - plain data used inline
      #   it 'returns a proper hash' do
      #     expect(parser.parse).to eq({a: 1, b: 2, c: 3})
      #   end
      #
      #   # good - compound matcher is extracted to a method
      #   def be_positive_and_rational
      #     be_positive.and be_rational
      #   end
      #
      #   it 'sums up to a positive rational' do
      #     expect(calculator.sum).to be_positive_and_rational
      #   end
      class MemoizedMatcher < Base
        include Variable

        MSG = 'Do not memoize matchers'

        # @!method expectation_matchers(example_group)
        #   Match expectation matchers used in the example group
        #
        #   @example source that matches
        #     describe Foo do
        #       it 'contains a list with a single one' do
        #         is_expected.to contain_exactly(eq_one)
        #       end
        #     end
        #
        #   @param example_group [RuboCop::AST::Node]
        #   @yieldparam [RuboCop::AST::Node] matchers
        def_node_search :expectation_matchers, <<~PATTERN
          (send
            {
              (send nil? #Expectations.all _ ?)          # expect(...), expect_any_instance_of or is_expected
              (block (send nil? #Expectations.all) ...)  # expect { ... }
            }
            #Runners.all  # .to or .not_to
            $send         # matcher
            _ ?           # an optional expectation failure message
          )
        PATTERN

        # @!method memoized_helper?(statement)
        #   Match memoized helpers
        #
        #   @example source that matches
        #     let(:be_heavy) { be > 5.ounces }
        #
        #   @param statement [RuboCop::AST::Node]
        #   @yield [helper_name, block_body] Gives helper name and definition
        def_node_matcher :memoized_helper?, <<~PATTERN
          (block
            (send nil?
              { #Helpers.all #Subjects.all }
              ({sym str} $_name)
            )
            _block_args $_block_body
          )
        PATTERN

        # @!method individual_matchers(matcher)
        #   Match individual matchers in a compound matcher
        #
        #   @example source that matches
        #     contains_exactly(be_one, be_two)
        #
        #   @param matcher [RuboCop::AST::Node]
        #   @yieldparam [RuboCop::AST::Node] individual matchers
        def_node_search :individual_matchers, <<~PATTERN
          (send nil? $%)
        PATTERN

        def on_block(example_group)
          return unless example_group?(example_group)

          helpers = helpers(example_group)
          helpers_names = Set.new(helpers.keys)

          expectation_matchers(example_group) do |matcher|
            individual_matchers(matcher, helpers_names) do |helper_name|
              add_offense(helpers[helper_name])
            end
          end
        end

        private

        def helpers(example_group)
          helpers = {}
          return helpers unless example_group.body

          example_group.body.each_child_node do |statement|
            memoized_helper?(statement) do |name, body|
              helpers[name.to_sym] = body
            end
          end
          helpers
        end
      end
    end
  end
end
