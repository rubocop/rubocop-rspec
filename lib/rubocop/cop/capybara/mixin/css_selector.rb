# frozen_string_literal: true

module RuboCop
  module Cop
    # Helps parsing css selector.
    module CssSelector
      COMMON_OPTIONS = %w[
        above below left_of right_of near count minimum maximum between text
        id class style visible obscured exact exact_text normalize_ws match
        wait filter_set focused
      ].freeze
      SPECIFIC_OPTIONS = {
        'button' => (
          COMMON_OPTIONS + %w[disabled name value title type]
        ).freeze,
        'link' => (
          COMMON_OPTIONS + %w[href alt title download]
        ).freeze,
        'table' => (
          COMMON_OPTIONS + %w[
            caption with_cols cols with_rows rows
          ]
        ).freeze,
        'select' => (
          COMMON_OPTIONS + %w[
            disabled name placeholder options enabled_options
            disabled_options selected with_selected multiple with_options
          ]
        ).freeze,
        'field' => (
          COMMON_OPTIONS + %w[
            checked unchecked disabled valid name placeholder
            validation_message readonly with type multiple
          ]
        ).freeze
      }.freeze
      SPECIFIC_PSEUDO_CLASSES = %w[
        not() disabled enabled checked unchecked
      ].freeze

      module_function

      # @param element [String]
      # @param attribute [String]
      # @return [Boolean]
      # @example
      #   specific_pesudo_classes?('button', 'name') # => true
      #   specific_pesudo_classes?('link', 'invalid') # => false
      def specific_options?(element, attribute)
        SPECIFIC_OPTIONS.fetch(element, []).include?(attribute)
      end

      # @param pseudo_class [String]
      # @return [Boolean]
      # @example
      #   specific_pesudo_classes?('disabled') # => true
      #   specific_pesudo_classes?('first-of-type') # => false
      def specific_pesudo_classes?(pseudo_class)
        SPECIFIC_PSEUDO_CLASSES.include?(pseudo_class)
      end

      # @param selector [String]
      # @return [Boolean]
      # @example
      #   id?('#some-id') # => true
      #   id?('.some-class') # => false
      def id?(selector)
        selector.start_with?('#')
      end

      # @param selector [String]
      # @return [Boolean]
      # @example
      #   attribute?('[attribute]') # => true
      #   attribute?('attribute') # => false
      def attribute?(selector)
        selector.start_with?('[')
      end

      # @param selector [String]
      # @return [Array<String>]
      # @example
      #   attributes('a[foo-bar_baz]') # => {"foo-bar_baz=>true}
      #   attributes('button[foo][bar]') # => {"foo"=>true, "bar"=>true}
      #   attributes('table[foo=bar]') # => {"foo"=>"'bar'"}
      def attributes(selector)
        selector.scan(/\[(.*?)\]/).flatten.to_h do |attr|
          key, value = attr.split('=')
          [key, normalize_value(value)]
        end
      end

      # @param selector [String]
      # @return [Boolean]
      # @example
      #   common_attributes?('a[focused]') # => true
      #   common_attributes?('button[focused][visible]') # => true
      #   common_attributes?('table[id=some-id]') # => true
      #   common_attributes?('h1[invalid]') # => false
      def common_attributes?(selector)
        attributes(selector).keys.difference(COMMON_OPTIONS).none?
      end

      # @param selector [String]
      # @return [Array<String>]
      # @example
      #   pseudo_classes('button:not([disabled])') # => ['not()']
      #   pseudo_classes('a:enabled:not([valid])') # => ['enabled', 'not()']
      def pseudo_classes(selector)
        # Attributes must be excluded or else the colon in the `href`s URL
        # will also be picked up as pseudo classes.
        # "a:not([href='http://example.com']):enabled" => "a:not():enabled"
        ignored_attribute = selector.gsub(/\[.*?\]/, '')
        # "a:not():enabled" => ["not()", "enabled"]
        ignored_attribute.scan(/:([^:]*)/).flatten
      end

      # @param selector [String]
      # @return [Boolean]
      # @example
      #   multiple_selectors?('a.cls b#id') # => true
      #   multiple_selectors?('a.cls') # => false
      def multiple_selectors?(selector)
        selector.match?(/[ >,+~]/)
      end

      # @param value [String]
      # @return [Boolean, String]
      # @example
      #   normalize_value('true') # => true
      #   normalize_value('false') # => false
      #   normalize_value(nil) # => false
      #   normalize_value("foo") # => "'foo'"
      def normalize_value(value)
        case value
        when 'true' then true
        when 'false' then false
        when nil then true
        else "'#{value}'"
        end
      end
    end
  end
end
