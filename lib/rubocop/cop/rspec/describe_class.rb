# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that the first argument to the top-level describe is a constant.
      #
      # @example
      #   # bad
      #   describe 'Do something' do
      #   end
      #
      #   # good
      #   describe TestedClass do
      #     subject { described_class }
      #   end
      #
      #   describe 'TestedClass::VERSION' do
      #     subject { Object.const_get(self.class.description) }
      #   end
      #
      #   describe "A feature example", type: :feature do
      #   end
      class DescribeClass < Base
        include RuboCop::RSpec::TopLevelGroup

        MSG = 'The first argument to describe should be '\
              'the class or module being tested.'

        def_node_matcher :rails_metadata?, <<-PATTERN
          (pair
            (sym :type)
            (sym { :channel :controller :helper :job :mailer :model :request
                   :routing :view :feature :system :mailbox })
          )
        PATTERN

        def_node_matcher :example_group_with_rails_metadata?, <<~PATTERN
          (send #rspec? :describe ... (hash <#rails_metadata? ...>))
        PATTERN

        def_node_matcher :not_a_const_described, <<~PATTERN
          (send #rspec? :describe $[!const !#string_constant?] ...)
        PATTERN

        def on_top_level_group(top_level_node)
          return if example_group_with_rails_metadata?(top_level_node.send_node)

          not_a_const_described(top_level_node.send_node) do |described|
            add_offense(described)
          end
        end

        private

        def string_constant?(described)
          described.str_type? &&
            described.value.match?(/^(?:(?:::)?[A-Z]\w*)+$/)
        end
      end
    end
  end
end
