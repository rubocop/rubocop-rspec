# frozen_string_literal: true

require 'regexp_parser'

module RuboCop
  module Cop
    module RSpec
      # Enforces the use of `include` matcher instead of `match` when the
      # matcher is a simple string literal without regex-specific features.
      #
      # When `match` is used with a regex that contains only literal characters
      # (no anchors, character classes, quantifiers, alternations, or
      # metacharacters), it's clearer to use the `include` matcher instead.
      #
      # @example
      #   # bad
      #   expect('foobar').to match(/foo/)
      #   expect(response.body).to match(/http:\/\/example\.com/)
      #
      #   # good
      #   expect('foobar').to include('foo')
      #   expect(response.body).to include('http://example.com')
      #
      #   # good - regex features needed
      #   expect('foobar').to match(/^foo/)     # anchor
      #   expect('foobar').to match(/foo\d+/)   # quantifier
      #   expect('foobar').to match(/foo[ob]/)  # character class
      #
      class MatchWithSimpleRegex < Base
        extend AutoCorrector

        MSG = 'Prefer using `include(%<string>s)` when the regex is a simple ' \
              'string literal.'
        RESTRICT_ON_SEND = %i[match].freeze

        # @!method match_with_regexp?(node)
        def_node_matcher :match_with_regexp?, <<~PATTERN
          (send nil? :match $regexp)
        PATTERN

        def on_send(node)
          match_with_regexp?(node) do |regexp|
            next unless simple_regexp?(regexp)

            string_literal = regexp_to_string(regexp)
            message = format(MSG, string: string_literal)

            add_offense(node, message: message) do |corrector|
              corrector.replace(node, "include(#{string_literal})")
            end
          end
        end

        private

        def simple_regexp?(node)
          return false if node.interpolation?
          return false if node.regopt.children.any?

          parsed = Regexp::Parser.parse(node.content)
          parsed.expressions.all? { |expr| simple_expression?(expr) }
        end

        def simple_expression?(expr)
          return false if expr.quantified?
          return true if expr.is_a?(Regexp::Expression::Literal)
          return true if expr.is_a?(Regexp::Expression::EscapeSequence::Literal)

          false
        end

        # Reconstruct the literal string that the regex matches
        def regexp_to_string(node)
          parsed = Regexp::Parser.parse(node.content)
          string_content = parsed.expressions.map do |expr|
            expr.respond_to?(:char) ? expr.char : expr.text
          end.join

          to_string_literal(string_content)
        end

        def to_string_literal(string)
          if string.include?("'")
            %("#{string.gsub('"', '\"')}")
          else
            "'#{string}'"
          end
        end
      end
    end
  end
end
