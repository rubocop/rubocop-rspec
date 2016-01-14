# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Do not use should when describing your tests.
      # see: http://betterspecs.org/#should
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
        MSG = 'Do not use should when describing your tests.'

        def on_block(node) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/LineLength
          method, = *node
          _, method_name, *args = *method

          return unless method_name == :it

          arguments = *args.first
          message = arguments.first.to_s
          return unless message.downcase.start_with?('should')

          arg1 = args.first.loc.expression
          message = Parser::Source::Range.new(arg1.source_buffer,
                                              arg1.begin_pos + 1,
                                              arg1.end_pos - 1)

          add_offense(message, message, MSG)
        end

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(range, corrected_message(range))
          end
        end

        private

        def corrected_message(range)
          range.source.split(' ').tap do |words|
            first_word = words.shift
            words.unshift('not') if first_word == "shouldn't"

            words.each_with_index do |value, key|
              next if ignored_words.include?(value)
              words[key] = simple_present(words[key])
              break
            end
          end.join(' ')
        end

        def simple_present(word)
          return custom_transform[word] if custom_transform[word]

          # ends with o s x ch sh or ss
          if %w(o s x]).include?(word[-1]) ||
              %w(ch sh ss]).include?(word[-2..-1])
            return "#{word}es"
          end

          # ends with y
          if word[-1] == 'y' && !%w(a u i o e).include?(word[-2])
            return "#{word[0..-2]}ies"
          end

          "#{word}s"
        end

        def custom_transform
          cop_config['CustomTransform'] || []
        end

        def ignored_words
          cop_config['IgnoredWords'] || []
        end
      end
    end
  end
end
