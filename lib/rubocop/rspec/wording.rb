# frozen_string_literal: true

module RuboCop
  module RSpec
    # RSpec example wording rewriter
    class Wording
      def initialize(text, ignore:, replace:)
        @text         = text
        @ignores      = ignore
        @replacements = replace
      end

      def rewrite
        text.split.tap do |words|
          first_word = words.shift
          words.unshift('not') if first_word.eql?("shouldn't")

          words.each_with_index do |value, key|
            next if ignores.include?(value)
            words[key] = simple_present(words.fetch(key))
            break
          end
        end.join(' ')
      end

      private

      attr_reader :text, :ignores, :replacements

      def simple_present(word)
        return replacements.fetch(word) if replacements.key?(word)

        # ends with o s x ch sh or ss
        if %w(o s x ch sh).any?(&word.public_method(:end_with?))
          return "#{word}es"
        end

        # ends with y
        if word.end_with?('y') && !%w(a u o e).include?(word[-2])
          return "#{word[0..-2]}ies"
        end

        "#{word}s"
      end
    end
  end
end
