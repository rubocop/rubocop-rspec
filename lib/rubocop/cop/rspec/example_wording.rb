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

        def on_block(node) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/LineLength
          method, = *node
          _, method_name, *args = *method

          return unless method_name.equal?(:it)

          arguments = args.first.to_a
          message = arguments.first.to_s
          return unless message.downcase.start_with?('should')

          arg1 = args.first.loc.expression
          message = Parser::Source::Range.new(arg1.source_buffer,
                                              arg1.begin_pos + 1,
                                              arg1.end_pos - 1)

          add_offense(message, message)
        end

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(
              range,
              RuboCop::RSpec::Wording.new(
                range.source,
                ignore: ignored_words,
                replace: custom_transform
              ).rewrite
            )
          end
        end

        private

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
