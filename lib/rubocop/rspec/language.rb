# frozen_string_literal: true

module RuboCop
  module RSpec
    # RSpec public API methods that are commonly used in cops
    module Language
      module ExampleGroups
        GROUPS  = %i(describe context feature example_group).freeze
        SKIPPED = %i(xdescribe xcontext xfeature).freeze
        FOCUSED = %i(fdescribe fcontext ffeature).freeze

        ALL = (GROUPS + SKIPPED + FOCUSED).freeze
      end

      module SharedGroups
        ALL = %i(shared_examples shared_context shared_examples_for).freeze
      end

      module Examples
        EXAMPLES = %i(it specify example scenario).freeze
        FOCUSED  = %i(fit fspecify fexample fscenario focus).freeze
        SKIPPED  = %i(xit xspecify xexample xscenario skip).freeze
        PENDING  = %i(pending).freeze

        ALL = (EXAMPLES + FOCUSED + SKIPPED + PENDING).freeze
      end

      module Hooks
        ALL = %i(after around before).freeze
      end

      module Helpers
        ALL = %i(let let!).freeze
      end

      ALL = (
        ExampleGroups::ALL +
        SharedGroups::ALL  +
        Examples::ALL      +
        Hooks::ALL         +
        Helpers::ALL
      ).freeze
    end
  end
end
