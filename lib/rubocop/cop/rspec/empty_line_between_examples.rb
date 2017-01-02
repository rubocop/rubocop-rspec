module RuboCop
  module Cop
    module RSpec
      # Check that examples are separated by empty lines.
      #
      # @example
      #
      #    # bad
      #
      #    describe User do
      #      it 'is not valid when email does not contain an @' do
      #        # ...
      #      end
      #      it 'validates phone number' do
      #        # ...
      #      end
      #    end
      #
      #    # good
      #
      #    describe User do
      #      it 'is not valid when email does not contain an @' do
      #        # ...
      #      end
      #
      #      it 'validates phone number' do
      #        # ...
      #      end
      #    end
      #
      class EmptyLineBetweenExamples < Cop
        MSG = 'Use empty lines between examples.'.freeze

        def on_block(node)
          return unless example_group?(node)

          touching_examples(node) do |offender|
            add_offense(offender, :expression)
          end
        end

        private

        def touching_examples(node)
          RuboCop::RSpec::ExampleGroup.new(node)
            .examples
            .map(&:to_node)
            .each_cons(2) do |above, below|
              yield(below) if (above.loc.end.line + 1).equal?(below.loc.line)
            end
        end
      end
    end
  end
end
