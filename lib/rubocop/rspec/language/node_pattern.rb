# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # Helper methods to detect RSpec DSL used with send and block
      # @deprecated Prefer using Node Pattern directly
      #   Use `'(block (send nil? #Example.all ...) ...)'` instead of
      #   `block_pattern('#Example.all')`
      module NodePattern
        # @deprecated Prefer using Node Pattern directly
        def send_pattern(string)
          "(send #rspec? #{string} ...)"
        end

        # @deprecated Prefer using Node Pattern directly
        def block_pattern(string)
          "(block #{send_pattern(string)} ...)"
        end

        # @deprecated Prefer using Node Pattern directly
        def numblock_pattern(string)
          "(numblock #{send_pattern(string)} ...)"
        end

        # @deprecated Prefer using Node Pattern directly
        def block_or_numblock_pattern(string)
          "{#{block_pattern(string)} #{numblock_pattern(string)}}"
        end
      end
    end
  end
end
