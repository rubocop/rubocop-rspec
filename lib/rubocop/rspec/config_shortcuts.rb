# frozen_string_literal: true

module RuboCop
  module RSpec
    # Config shortcuts for RuboCop::Cop::Rspec::Cop
    # and Rubocop::RSpec::ExampleGroup
    module ConfigShortcuts
      def rspec_aliases(setting)
        config
          .for_all_cops
          .fetch('RSpec', {})
          .fetch('Aliases', {})
          .fetch(setting, [])
          .map(&:to_sym)
      end
    end
  end
end
