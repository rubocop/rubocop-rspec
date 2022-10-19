# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps check offenses with variable definitions
      module SkipOrPending
        extend RuboCop::NodePattern::Macros

        # @!method skipped_in_metadata?(node)
        def_node_matcher :skipped_in_metadata?, <<-PATTERN
          {
            (send _ _ <#skip_or_pending? ...>)
            (send _ _ ... (hash <(pair #skip_or_pending? { true str }) ...>))
          }
        PATTERN

        # @!method skip_or_pending?(node)
        def_node_matcher :skip_or_pending?, '{(sym :skip) (sym :pending)}'
      end
    end
  end
end
