module RuboCop
  module Cop # rubocop:disable Style/Documentation
    WorkaroundCop = Cop.dup

    # Clone of the the normal RuboCop::Cop::Cop class so we can rewrite
    # the inherited method without breaking functionality
    class WorkaroundCop
      # Overwrite the cop inherited method to be a noop. Our RSpec::Cop
      # class will invoke the inherited hook instead
      def self.inherited(*)
      end

      # Special case `Module#<` so that the rspec support rubocop exports
      # is compatible with our subclass
      def self.<(other)
        other.equal?(RuboCop::Cop::Cop) || super
      end
    end
    private_constant(:WorkaroundCop)

    module RSpec
      # @abstract parent class to rspec cops
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
      #       - '_test.rb$'
      #       - '(?:^|/)test/'
      class Cop < WorkaroundCop
        DEFAULT_CONFIGURATION =
          RuboCop::RSpec::CONFIG.fetch('AllCops').fetch('RSpec')

        include RuboCop::RSpec::Language, RuboCop::RSpec::Language::NodePattern

        # Invoke the original inherited hook so our cops are recognized
        def self.inherited(subclass)
          RuboCop::Cop::Cop.inherited(subclass)
        end

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
end
