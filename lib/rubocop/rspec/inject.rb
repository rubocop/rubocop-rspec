# encoding: utf-8

require 'yaml'

module RuboCop
  module RSpec
    # Because RuboCop doesn't yet support plugins, we have to monkey patch in a
    # bit of our configuration.
    module Inject
      DEFAULT_FILE = File.expand_path(
        '../../../../config/default.yml', __FILE__
      )

      def self.defaults!
        hash = YAML.load_file(DEFAULT_FILE)
        puts "configuration from #{DEFAULT_FILE}" if ConfigLoader.debug?
        config = ConfigLoader.merge_with_default(hash, DEFAULT_FILE)

        ConfigLoader.instance_variable_set(:@default_configuration, config)
      end
    end
  end
end
