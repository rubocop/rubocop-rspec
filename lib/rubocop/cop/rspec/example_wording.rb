# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that example descriptions do not start with "should".
      #
      # @see http://betterspecs.org/#should
      #
      # The autocorrect is experimental - use with care! It can be configured
      # with CustomTransform (e.g. have => has) and IgnoredWords (e.g. only).
      #
      # @example
      #   # bad
      #   it 'should find nothing' do
      #   end
      #
      #   # good
      #   it 'finds nothing' do
      #   end
      class ExampleWording < Cop
        MSG = 'Do not use should when describing your tests.'.freeze

        def_node_matcher(
          :it_description,
          '(block (send _ :it $(str $_) ...) ...)'
        )

        def on_block(node)
          it_description(node) do |description_node, message|
            return unless message.downcase.start_with?('should')

            add_wording_offense(description_node)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(
              range,
              RuboCop::RSpec::Wording.new(
                range.source,
                ignore:  ignored_words,
                replace: custom_transform
              ).rewrite
            )
          end
        end

        private

        def add_wording_offense(node)
          expr = node.loc.expression

          message =
            Parser::Source::Range.new(
              expr.source_buffer,
              expr.begin_pos + 1,
              expr.end_pos - 1
            )

          add_offense(message, message)
        end

        def custom_transform
          cop_config.fetch('CustomTransform', {})
        end

        def ignored_words
          cop_config.fetch('IgnoredWords', [])
        end
      end
    end
  end
end
