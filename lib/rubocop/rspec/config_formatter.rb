require 'yaml'

module RuboCop
  module RSpec
    # Builds a YAML config file from two config hashes
    class ConfigFormatter
      NAMESPACES = /^(#{Regexp.union('RSpec', 'FactoryGirl')})/

      def initialize(config, descriptions)
        @config       = config
        @descriptions = descriptions
      end

      def dump
        YAML.dump(unified_config).gsub(NAMESPACES, "\n\\1")
      end

      private

      def unified_config
        cops.each_with_object(config.dup) do |cop, unified|
          unified[cop] = config.fetch(cop).merge(descriptions.fetch(cop))
        end
      end

      def cops
        (descriptions.keys | config.keys).grep(NAMESPACES)
      end

      attr_reader :config, :descriptions
    end
  end
end
