# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that spec file paths are consistent and well-formed.
      #
      # `IgnoreMetadata` accepts a Hash or an Array. The Hash format matches
      # metadata key/value pairs, such as `type: :routing` with the default
      # `IgnoreMetadata: {type=>routing}`. This format remains supported.
      # The Hash format compares Symbol metadata values with String config
      # values, so `type: :routing` matches but `type: 'routing'` does not.
      #
      # Use the Array format to ignore several values for the same key, or to
      # ignore a key regardless of its value. For example, `[prepare,
      # {type=>model}, {type=>routing}]` ignores groups with `:prepare`,
      # `prepare: false`, `prepare: nil`, `type: :model` or `type: :routing`.
      # Any matching entry or key/value pair is enough to ignore a group.
      #
      # Configure this Array in YAML with separate entries:
      #
      #   RSpec/SpecFilePathFormat:
      #     IgnoreMetadata:
      #       - prepare
      #       - type: model
      #       - type: routing
      #       - resources: [database, network]
      #
      # Separate Hash entries allow several values for the same key without
      # duplicate YAML keys. Each `-` starts a new Array entry; the two `type`
      # keys belong to different Hashes, so neither replaces the other.
      #
      # Array entries match both String and Symbol metadata keys by spelling.
      # For example, `prepare` also matches `"prepare" => false`. When both
      # key forms are present, their values remain separate alternatives.
      #
      # In the Array format, a configured value of `model` matches both
      # `type: :model` and `type: 'model'`. String and Symbol values compare by
      # their spelling, including inside Arrays. Array values must match the
      # complete Array in the same order.
      #
      # The Array format reads metadata arguments written on the top-level
      # example group, such as `describe MyClass, :prepare, type: :model`.
      # It does not evaluate variables or method calls, or read metadata added
      # by RSpec configuration. A key can still match a presence entry when
      # its value is unknown, but cannot match a configured literal value.
      #
      # An Array replaces the default `IgnoreMetadata: {type=>routing}`.
      # Include `{type=>routing}` in an Array to keep ignoring routing specs.
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
      #   my_class/_partial_spec.rb # describe MyClass
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
      # @example `IgnoreMetadata: [prepare, {type=>model}, {type=>routing}]`
      #   # good
      #   whatever_spec.rb         # describe MyClass, :prepare do; end
      #   whatever_spec.rb         # describe MyClass, prepare: false do; end
      #   whatever_spec.rb         # describe MyClass, type: :model do; end
      #   whatever_spec.rb         # describe MyClass, type: :routing do; end
      #
      # @example `IgnoreMetadata: [{resources=>[database, network]}]`
      #   # good
      #   x_spec.rb # describe MyClass, resources: %i[database network] do; end
      #
      #   # bad
      #   x_spec.rb # describe MyClass, resources: :database do; end
      #   x_spec.rb # describe MyClass, resources: %i[network database] do; end
      #
      # @example `EnforcedInflector: active_support`
      #   # Enable to use ActiveSupport's inflector for custom acronyms
      #   # like HTTP, etc. Set to "default" by default.
      #   # Configure `InflectorPath` with the path to the inflector file.
      #   # The default is ./config/initializers/inflections.rb.
      #
      class SpecFilePathFormat < Base
        include TopLevelGroup
        include Namespace
        include FileHelp

        MSG = 'Spec path should end with `%<suffix>s`.'
        PATH_NAME_BOUNDARY = '(?![[:alnum:]])'
        PARTIAL_SPEC_FILE = %r{/(_[^/]*_spec\.rb)\z}.freeze

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

        private

        # Matches explicit RSpec metadata against list-format filters.
        class MetadataFilter
          UNKNOWN_METADATA = Object.new.freeze
          STATIC_VALUES = %i[true false nil].zip([true, false, nil]).to_h.freeze
          private_constant :UNKNOWN_METADATA, :STATIC_VALUES

          def initialize(entries)
            @entries = entries
          end

          def ignored?(arguments)
            metadata = explicit_metadata(arguments)
            @entries.any? do |entry|
              ignored_metadata_entry?(entry, metadata)
            end
          end

          private

          def ignored_metadata_entry?(entry, metadata)
            case entry
            when Hash
              entry.any? do |key, value|
                [key.to_s, key.to_s.to_sym].any? do |metadata_key|
                  metadata.key?(metadata_key) &&
                    metadata[metadata_key] == normalize_metadata_value(value)
                end
              end
            when String, Symbol
              metadata.key?(entry.to_s) || metadata.key?(entry.to_sym)
            else
              false
            end
          end

          def explicit_metadata(arguments)
            arguments = arguments.dup
            hash = arguments.pop if arguments.last&.hash_type?
            metadata = hash_metadata(hash)
            metadata[arguments.pop.value] = true while arguments.last&.sym_type?
            metadata
          end

          def hash_metadata(hash)
            return {} unless hash

            hash.children.each_with_object({}) do |node, metadata|
              if node.pair_type? && node.key.type?(:sym, :str)
                key = node.key.value
                metadata[key] = literal_metadata_value(node.value)
              elsif unknown_metadata_key?(node)
                metadata.transform_values! { UNKNOWN_METADATA }
              end
            end
          end

          def unknown_metadata_key?(node)
            !node.pair_type? || !node.key.basic_literal?
          end

          def literal_metadata_value(node)
            case node.type
            when :array
              node.children.map { |child| literal_metadata_value(child) }
            when :sym
              node.value.to_s
            when :str, :int, :float
              node.value
            else
              STATIC_VALUES.fetch(node.type, UNKNOWN_METADATA)
            end
          end

          def normalize_metadata_value(value)
            case value
            when Array
              value.map { |item| normalize_metadata_value(item) }
            when Symbol
              value.to_s
            else
              value
            end
          end
        end
        private_constant :MetadataFilter

        # Inflector module that uses ActiveSupport for advanced inflection rules
        module ActiveSupportInflector
          def self.call(string)
            ActiveSupport::Inflector.underscore(string)
          end

          def self.prepare_availability(inflector_path)
            return if @prepared

            @prepared = true

            unless File.exist?(inflector_path)
              raise "The configured `InflectorPath` #{inflector_path} does " \
                    'not exist.'
            end

            require 'active_support/inflector'
            require inflector_path
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
          case cop_config.fetch('EnforcedInflector')
          when 'active_support'
            ActiveSupportInflector.prepare_availability(inflector_path)
            ActiveSupportInflector
          when 'default'
            DefaultInflector
          end
        end

        def inflector_path
          File.expand_path(
            cop_config.fetch('InflectorPath'),
            config.base_dir_for_path_parameters
          )
        end

        def ensure_correct_file_path(send_node, class_name, arguments)
          pattern = correct_path_pattern(class_name, arguments)
          return if filename_ends_with?(pattern)

          # For the suffix shown in the offense message, modify the regular
          # expression pattern to resemble a glob pattern for clearer error
          # messages.
          suffix = pattern
            .sub(PATH_NAME_BOUNDARY, '')
            .sub('.*', '*')
            .sub('[^/]*', '*')
            .sub('\.', '.')
          add_offense(send_node, message: format(MSG, suffix: suffix))
        end

        def ignore_metadata?(arguments)
          if ignore_metadata.is_a?(Array)
            return MetadataFilter.new(ignore_metadata).ignored?(arguments)
          end
          return false unless ignore_metadata.is_a?(Hash)

          arguments.any? do |argument|
            metadata_key_value(argument).any? do |key, value|
              ignore_metadata.values_at(key.to_s).include?(value.to_s)
            end
          end
        end

        def correct_path_pattern(class_name, arguments)
          [
            expected_path(class_name),
            PATH_NAME_BOUNDARY,
            method_name_pattern(arguments.first),
            '[^/]*_spec\.rb'
          ].join
        end

        def method_name_pattern(method_name)
          return if ignore_method_name?(method_name)

          ".*#{method_name.str_content.gsub(/\s/, '_').gsub(/\W/, '')}"
        end

        def ignore_method_name?(method_name)
          !method_name&.str_type? || ignore_methods?
        end

        def expected_path(constant)
          constants = namespace(constant) + constant.const_name.split('::')

          File.join(
            constants.filter_map do |name|
              path = custom_transform.fetch(name) { camel_to_snake_case(name) }
              path unless path.empty?
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
          file_path_for_matching.match?(%r{(?:\A|/)#{pattern}$})
        end

        def file_path_for_matching
          expanded_file_path.sub(PARTIAL_SPEC_FILE, '\1')
        end
      end
    end
  end
end
