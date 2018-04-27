module RuboCop
  module Cop
    module RSpec
      # Check `describe` argument format.
      #
      # Make sure that `describe` argument starts with . for class methods or
      # # for instance methods.
      #
      # @example
      #   # bad
      #   describe 'method_name' do
      #     # ...
      #   end
      #
      #   # good
      #   describe '#method_name' do
      #     # ...
      #   end
      class DescribeMethodFormat < Cop
        MSG = 'Use # for instance methods or . for class methods when ' \
              'describing class method'.freeze

        def_node_matcher :describe_method_format?, <<-PATTERN
          (send {(const nil? :Rspec) nil?} :describe $(str #bad_describe_format?))
        PATTERN

        def bad_describe_format?(method_name)
          method_name.match(/\A[^.#]/)
        end

        def on_send(node)
          describe_method_format?(node) do |match|
            add_offense(match, location: :expression)
          end
        end
      end
    end
  end
end
