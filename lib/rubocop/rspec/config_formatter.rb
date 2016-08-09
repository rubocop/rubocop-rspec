module RuboCop
  module RSpec
    # Builds a YAML config file from two config hashes
    class ConfigFormatter
      NAMESPACE = 'RSpec'.freeze

      def initialize(config, descriptions)
        @config       = config
        @descriptions = descriptions
      end

      def dump
        YAML.dump(unified_config).gsub(/^#{NAMESPACE}/, "\n#{NAMESPACE}")
      end

      private

      def unified_config
        cops.each_with_object(config.dup) do |cop, unified|
          unified[cop] = descriptions.fetch(cop).merge(config.fetch(cop))
        end
      end

      def cops
        (descriptions.keys + config.keys).uniq.grep(/\A#{NAMESPACE}/)
      end

      attr_reader :config, :descriptions
    end
  end
end
