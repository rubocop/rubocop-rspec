# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps parsing css selector.
      module CssSelector
        module_function

        # @param selector [String]
        # @return [String]
        # @example
        #   id('#some-id') # => some-id
        #   id('.some-class') # => nil
        #   id('#some-id.cls') # => some-id
        def id(selector)
          return unless id?(selector)

          selector.gsub(selector.scan(/[^\\]([>,+~.].*)/).join, '')
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
        # @return [Array<String>]
        # @example
        #   classes('#some-id') # => []
        #   classes('.some-class') # => ['some-class']
        #   classes('#some-id.some-class') # => ['some-class']
        #   classes('#some-id.cls1.cls2') # => ['cls1', 'cls2']
        def classes(selector)
          selector.scan(/.([\w-]*)/).flatten
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
            value << ']' if value&.include?('[')
            [key, normalize_value(value)]
          end
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
          normalize = selector.gsub(/(\\[>,+~]|\(.*\))/, '')
          normalize.match?(/[ >,+~]/)
        end

        # @param value [String]
        # @return [Boolean, String]
        # @example
        #   normalize_value('true') # => true
        #   normalize_value('false') # => false
        #   normalize_value(nil) # => nil
        #   normalize_value("foo") # => "'foo'"
        def normalize_value(value)
          case value
          when 'true' then true
          when 'false' then false
          when nil then nil
          else "'#{value.gsub(/["']/, '')}'"
          end
        end
      end
    end
  end
end
