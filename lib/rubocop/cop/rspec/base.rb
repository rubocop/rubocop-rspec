# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # @abstract parent class to RSpec cops
      #
      # The criteria for whether rubocop-rspec analyzes a certain ruby file
      # is configured via `AllCops/RSpec`. For example, if you want to
      # customize your project to scan all files within a `test/` directory
      # then you could add this to your configuration:
      #
      # @example configuring analyzed paths
      #   # .rubocop.yml
      #   # AllCops:
      #   #   RSpec:
      #   #     Patterns:
      #   #     - '_test.rb$'
      #   #     - '(?:^|/)test/'
      class Base < ::RuboCop::Cop::Base
        include RuboCop::RSpec::Language
        include RuboCop::RSpec::Language::NodePattern

        # Invoke the original inherited hook so our cops are recognized
        def self.inherited(subclass) # rubocop:disable Lint/MissingSuper
          RuboCop::Cop::Base.inherited(subclass)
        end

        def relevant_file?(file)
          relevant_rubocop_rspec_file?(file) && super
        end

        private

        def relevant_rubocop_rspec_file?(file)
          self.class.rspec_pattern.match?(file)
        end

        class << self
          def rspec_pattern
            @rspec_pattern ||=
              Regexp.union(
                rspec_pattern_config.map(&Regexp.public_method(:new))
              )
          end

          private

          def rspec_pattern_config
            default_configuration =
              RuboCop::RSpec::CONFIG.fetch('AllCops').fetch('RSpec')

            Config.new
              .for_all_cops
              .fetch('RSpec', default_configuration)
              .fetch('Patterns')
          end
        end
      end
    end
  end
end
