# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that spec file paths are consistent and well-formed.
      #
      # `IgnoreMetadata` allows to ignore specs based on the top-level
      # example group's metadata. It accepts a Hash or an Array.
      # It accepts multiple separate entries; they are alternatives, not
      # combinations of metadata conditions.
      #
      # The Array format allows defining several values for the same key, and
      # match on key-only with the RSpec semantics.
      #
      # Each entry must contain at most one key/value pair.
      #
      # A scalar entry such as `prepare` matches a bare `:prepare` or
      # literal `prepare: true`, but not `prepare: false` or any other value.
      # As in RSpec, a bare tag overrides the same Symbol key in the
      # metadata Hash.
      #
      # Keys and string values are treated as Symbols, so `type: routing`
      # matches `type: :routing` but not `type: 'routing'`. Numbers, `true`,
      # `false` and `~` (`nil`) match as is.
      #
      # The `-` starts a new Array entry. For example:
      #
      #   RSpec/SpecFilePathFormat:
      #     IgnoreMetadata:
      #       - prepare # ignores groups with `:prepare` or `prepare: true`
      #       - type: model
      #       - type: routing
      #
      # The Hash format matches metadata key/value pairs, such as
      # `type: :routing` with `IgnoreMetadata: {type=>routing}`.
      #
      # User entries merge with the default `- type: routing` filter.
      # To replace the default, configure `inherit_mode` for this cop:
      #
      #   RSpec/SpecFilePathFormat:
      #     inherit_mode:
      #       override: [IgnoreMetadata]
      #     IgnoreMetadata: []
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
      # @example `IgnoreMetadata: [{type=>routing}]` (default)
      #   # good
      #   whatever_spec.rb         # describe MyClass, type: :routing do; end
      #
      # @example `IgnoreMetadata: [prepare, {type=>model}, {type=>routing}]`
      #   # good
      #   whatever_spec.rb         # describe MyClass, :prepare do; end
      #   whatever_spec.rb         # describe MyClass, prepare: true do; end
      #   whatever_spec.rb         # describe MyClass, type: :model do; end
      #   whatever_spec.rb         # describe MyClass, type: :routing do; end
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

        def validate_config
          metadata_filter
        end

        def on_top_level_example_group(node)
          return unless top_level_groups.one?

          example_group_arguments(node) do |send_node, class_name, arguments|
            next if !class_name.const_type? || ignore_metadata?(arguments)

            ensure_correct_file_path(send_node, class_name, arguments)
          end
        end

        private

        # Matches explicit RSpec metadata against `IgnoreMetadata` entries.
        class MetadataFilter
          UNKNOWN = Object.new.freeze
          LITERALS = %i[true false nil].zip([true, false, nil]).to_h.freeze
          private_constant :UNKNOWN, :LITERALS

          def initialize(config)
            @entries =
              case config
              when Hash then config.map { |key, value| entry(key, value) }
              when Array then config.flat_map { |item| list_entries(item) }
              else config_error!('must be a list')
              end
          end

          def ignored?(arguments)
            metadata = explicit_metadata(arguments)
            @entries.any? do |key, value|
              metadata.fetch(key, UNKNOWN).eql?(value)
            end
          end

          private

          def list_entries(item)
            case item
            when String, Symbol then [entry(item, true)]
            when Hash then hash_entries(item)
            # NOTE: RuboCop converts a user's Hash into `[key, value]` pairs
            # when merging it with the default list (see `inherit_mode`).
            # TODO: Remove this, and the Hash format, in the next major version.
            when Array
              item.size == 2 ? [entry(*item)] : invalid_entry!(item)
            else invalid_entry!(item)
            end
          end

          def hash_entries(item)
            if item.size > 1
              config_error!('list entries must contain at most one key/value ' \
                            'pair. Split multiple pairs into separate list ' \
                            'entries.')
            end
            item.map { |key, value| entry(key, value) }
          end

          def entry(key, value)
            invalid_entry!(key) unless key.is_a?(String) || key.is_a?(Symbol)

            [key.to_sym, value.is_a?(String) ? value.to_sym : value]
          end

          def invalid_entry!(item)
            config_error!('entries must be tags or `key: value` pairs, ' \
                          "got: #{item.inspect}")
          end

          def config_error!(message)
            raise ValidationError,
                  "RSpec/SpecFilePathFormat IgnoreMetadata #{message}"
          end

          def explicit_metadata(arguments)
            arguments = arguments.dup
            metadata = arguments.last&.hash_type? ? literals(arguments.pop) : {}
            apply_metadata_tags(metadata, arguments)
          end

          def apply_metadata_tags(metadata, arguments)
            tags = arguments.reverse.take_while(&:any_sym_type?)
            if uncertain_metadata_tags?(arguments, tags)
              invalidate_metadata_values!(metadata)
            end
            tags.each_with_object(metadata) do |node, result|
              result[node.value] = true if node.sym_type?
            end
          end

          # Positional Symbols can only overwrite Hash values with true.
          def invalidate_metadata_values!(metadata)
            metadata.transform_values! { |value| value.equal?(true) || UNKNOWN }
          end

          def uncertain_metadata_tags?(arguments, tags)
            previous = arguments[-tags.size - 1]
            tags.any?(&:dsym_type?) || unknown_metadata_argument?(previous)
          end

          def unknown_metadata_argument?(node)
            node && !node.basic_literal? &&
              !node.type?(:array, :hash, :dstr, :regexp, :dregx)
          end

          def literals(hash)
            hash.children.each_with_object({}) do |node, metadata|
              if node.pair_type? && node.key.sym_type?
                metadata[node.key.value] = metadata_value(node.value)
              elsif unknown_metadata_key?(node)
                metadata.transform_values! { UNKNOWN }
              end
            end
          end

          def unknown_metadata_key?(node)
            !node.pair_type? || !node.key.basic_literal?
          end

          def metadata_value(node)
            return node.value if node.type?(:sym, :int, :float)

            LITERALS.fetch(node.type, UNKNOWN)
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
          metadata_filter.ignored?(arguments)
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
              path = custom_transform.fetch(name) { inflector.call(name) }
              path unless path.empty?
            end
          )
        end

        def custom_transform
          cop_config.fetch('CustomTransform', {})
        end

        def ignore_methods?
          cop_config['IgnoreMethods']
        end

        def metadata_filter
          @metadata_filter ||=
            MetadataFilter.new(cop_config.fetch('IgnoreMetadata', []))
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
