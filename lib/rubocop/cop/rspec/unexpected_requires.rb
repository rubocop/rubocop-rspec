# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that rspec files do not contain requires, as this
      # can lead to unexpected behavior later when the code is
      # not used with rspec.
      #
      # Require the necessary files in the projects config or
      # where you need it instead.
      #
      # @example
      #   # bad
      #   require "lib/use_cases/my_work"
      #
      #   describe UseCases::MyWork do
      #     ...
      #   end
      #
      #   # good
      #   describe UseCases::MyWork do
      #     ...
      #   end
      #
      class UnexpectedRequires < Base
        MSG = 'Do not require anything in a test file.'

        IGNORED_PATTERN = /(spec|rails)_helper/

        def on_new_investigation
          return if processed_source.path.match?(IGNORED_PATTERN)

          unnecessary_requires.each do |token|
            add_offense(token.pos, message: MSG)
          end
        end

        private

        def unnecessary_requires
          require_tokens.filter_map do |token|
            stmt = processed_source.lines[token.line - 1] # line is 1-indexed
            next if stmt.match?(IGNORED_PATTERN)

            token
          end.compact
        end

        def require_tokens
          processed_source.tokens.select do |token|
            next if token.comment?

            token.type == :tIDENTIFIER && token.text == 'require'
          end
        end
      end
    end
  end
end
