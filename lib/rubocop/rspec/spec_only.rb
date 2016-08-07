# frozen_string_literal: true

module RuboCop
  module RSpec
    # Mixin for cops that skips non-spec files
    #
    # The criteria for whether rubocop-rspec analyzes a certain ruby file
    # is configured via `AllCops/RSpec`. For example, if you want to
    # customize your project to scan all files within a `test/` directory
    # then you could add this to your configuration:
    #
    # @example configuring analyzed paths
    #
    #   AllCops:
    #     RSpec:
    #       Patterns:
    #       - '_spec.rb$'
    #       - '(?:^|/)spec/'
    #
    # @note this functionality is implemented via this mixin instead of
    #   a subclass of `RuboCop::Cop::Cop` because the `Cop` class assumes
    #   that it will be the direct superclass of all cops. For example,
    #   if the ancestry of a cop looked like this:
    #
    #     class RuboCop::RSpec::Cop < RuboCop::Cop::Cop
    #     end
    #
    #     class RuboCop::RSpec::SpecCop < RuboCop::RSpec::Cop
    #     end
    #
    #   then `SpecCop` will fail to be registered on the class instance
    #   variable of `Cop` which tracks all descendants via `.inherited`.
    #
    #   While we could match this behavior and provide a rubocop-rspec Cop
    #   parent class, it would rely heavily on the implementation details
    #   of RuboCop itself which is largly private API. This would be
    #   irresponsible since any patch level release of rubocop could break
    #   integrations for users of rubocop-rspec
    #
    module SpecOnly
      DEFAULT_CONFIGURATION = CONFIG.fetch('AllCops').fetch('RSpec')

      def relevant_file?(file)
        rspec_pattern =~ file && super
      end

      private

      def rspec_pattern
        Regexp.union(rspec_pattern_config.map(&Regexp.public_method(:new)))
      end

      def rspec_pattern_config
        config
          .for_all_cops
          .fetch('RSpec', DEFAULT_CONFIGURATION)
          .fetch('Patterns')
      end
    end
  end
end
