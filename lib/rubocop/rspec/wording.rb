# frozen_string_literal: true

module RuboCop
  module RSpec
    # RSpec example wording rewriter
    class Wording
      def initialize(range, ignore:, replace:)
        @range        = range
        @ignores      = ignore
        @replacements = replace
      end

      def rewrite
        range.source.split(' ').tap do |words|
          first_word = words.shift
          words.unshift('not') if first_word == "shouldn't"

          words.each_with_index do |value, key|
            next if ignores.include?(value)
            words[key] = simple_present(words[key])
            break
          end
        end.join(' ')
      end

      private

      attr_reader :range, :ignores, :replacements

      def simple_present(word)
        return replacements[word] if replacements[word]

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
    end
  end
end
