# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that spec file paths are consistent and well-formed.
      #
      # @example
      #   # bad
      #   whatever_spec.rb         # describe MyClass
      #   my_class_spec.rb         # describe MyClass, '#method'
      #
      #   # good
      #   my_class_spec.rb         # describe MyClass
      #   my_class_method_spec.rb  # describe MyClass, '#method'
      #   my_class/method_spec.rb  # describe MyClass, '#method'
      #
      # @example `CustomTransform: {RuboCop=>rubocop, RSpec=>rspec}` (default)
      #   # good
      #   rubocop_spec.rb          # describe RuboCop
      #   rspec_spec.rb            # describe RSpec
      #
      # @example `IgnoreMethods: false` (default)
      #   # bad
      #   my_class_spec.rb         # describe MyClass, '#method'
      #
      # @example `IgnoreMethods: true`
      #   # good
      #   my_class_spec.rb         # describe MyClass, '#method'
      #
      # @example `IgnoreMetadata: {type=>routing}` (default)
      #   # good
      #   whatever_spec.rb         # describe MyClass, type: :routing do; end
      #
      # @example `UseActiveSupportInflections: true`
      #   # Enable to use ActiveSupport's inflector for custom acronyms
      #   # like HTTP, etc. Set to false by default.
      #   # The InflectorPath provides the path to the inflector file.
      #   # The default is ./config/initializers/inflections.rb.
      #
      class SpecFilePathFormat < Base
        include TopLevelGroup
        include Namespace
        include FileHelp

        MSG = 'Spec path should end with `%<suffix>s`.'

        # @!method example_group_arguments(node)
        def_node_matcher :example_group_arguments, <<~PATTERN
          (block $(send #rspec? #ExampleGroups.all $_ $...) ...)
        PATTERN

        # @!method metadata_key_value(node)
        def_node_search :metadata_key_value, '(pair (sym $_key) (sym $_value))'

        def on_top_level_example_group(node)
          return unless top_level_groups.one?

          example_group_arguments(node) do |send_node, class_name, arguments|
            next if !class_name.const_type? || ignore_metadata?(arguments)

            ensure_correct_file_path(send_node, class_name, arguments)
          end
        end

        # For testing and debugging
        def self.reset_activesupport_cache!
          ActiveSupportInflector.reset_cache!
        end

        private

        # Inflector module that uses ActiveSupport for advanced inflection rules
        module ActiveSupportInflector
          def self.call(string)
            ActiveSupport::Inflector.underscore(string)
          end

          def self.available?(cop_config)
            return @available unless @available.nil?

            unless cop_config.fetch('UseActiveSupportInflections', false)
              return @available = false
            end

            unless File.exist?(inflector_path(cop_config))
              return @available = false
            end

            @available = begin
              require 'active_support/inflector'
              require inflector_path(cop_config)
              true
            rescue LoadError, StandardError
              false
            end
          end

          def self.inflector_path(cop_config)
            cop_config.fetch('InflectorPath',
                             './config/initializers/inflections.rb')
          end

          def self.reset_cache!
            @available = nil
          end
        end

        # Inflector module that uses basic regex-based conversion
        module DefaultInflector
          def self.call(string)
            string
              .gsub(/([^A-Z])([A-Z]+)/, '\1_\2')
              .gsub(/([A-Z])([A-Z][^A-Z\d]+)/, '\1_\2')
              .downcase
          end
        end

        def inflector
          @inflector ||= if ActiveSupportInflector.available?(cop_config)
                           ActiveSupportInflector
                         else
                           DefaultInflector
                         end
        end

        def ensure_correct_file_path(send_node, class_name, arguments)
          pattern = correct_path_pattern(class_name, arguments)
          return if filename_ends_with?(pattern)

          # For the suffix shown in the offense message, modify the regular
          # expression pattern to resemble a glob pattern for clearer error
          # messages.
          suffix = pattern.sub('.*', '*').sub('[^/]*', '*').sub('\.', '.')
          add_offense(send_node, message: format(MSG, suffix: suffix))
        end

        def ignore_metadata?(arguments)
          arguments.any? do |argument|
            metadata_key_value(argument).any? do |key, value|
              ignore_metadata.values_at(key.to_s).include?(value.to_s)
            end
          end
        end

        def correct_path_pattern(class_name, arguments)
          path = [expected_path(class_name)]
          path << '.*' unless ignore?(arguments.first)
          path << [name_pattern(arguments.first), '[^/]*_spec\.rb']
          path.join
        end

        def name_pattern(method_name)
          return if ignore?(method_name)

          method_name.str_content.gsub(/\s/, '_').gsub(/\W/, '')
        end

        def ignore?(method_name)
          !method_name&.str_type? || ignore_methods?
        end

        def expected_path(constant)
          constants = namespace(constant) + constant.const_name.split('::')

          File.join(
            constants.map do |name|
              custom_transform.fetch(name) { camel_to_snake_case(name) }
            end
          )
        end

        def camel_to_snake_case(string)
          inflector.call(string)
        end

        def custom_transform
          cop_config.fetch('CustomTransform', {})
        end

        def ignore_methods?
          cop_config['IgnoreMethods']
        end

        def ignore_metadata
          cop_config.fetch('IgnoreMetadata', {})
        end

        def filename_ends_with?(pattern)
          expanded_file_path.match?("#{pattern}$")
        end
      end
    end
  end
end
