# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that rspec files do not contain requires.
      #
      # As this can lead to unexpected behavior 
      # later when the code is not used with rspec.
      #
      # Require the necessary files in the projects config or
      # where you need it instead.
      #
      # @example
      #   # bad
      #   require "lib/use_cases/my_work"
      #
      #   describe UseCases::MyWork do
      #     
      #   end
      #
      #   # good
      #   describe UseCases::MyWork do
      #     
      #   end
      #
      class UnexpectedRequires < Base
        MSG = 'Do not require anything in a test file.'

        IGNORED_PATTERN = /(spec|rails)_helper/
        
        def_node_matcher :require_symbol?, <<~PATTERN
          (send #rspec? :require $_ ...)
        PATTERN

        def on_new_investigation
          @ignore_file = processed_source.path.match?(IGNORED_PATTERN)
        end

        def on_send(node)
          return if @ignore_file

          require_symbol?(node) do |match|
            next if match.value.match?(IGNORED_PATTERN)

            add_offense(node, message: MSG)
          end 
        end
      end
    end
  end
end
