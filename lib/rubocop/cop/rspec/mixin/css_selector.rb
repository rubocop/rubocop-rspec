# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps parsing css selector.
      module CssSelector
        COMMON_OPTIONS = %w[
          above below left_of right_of near count minimum maximum between text
          id class style visible obscured exact exact_text normalize_ws match
          wait filter_set focused
        ].freeze

        module_function

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
        #   multiple_selectors?('a.cls b#id') # => true
        #   multiple_selectors?('a.cls') # => false
        def multiple_selectors?(selector)
          selector.match?(/[ >,+]/)
        end

        # @param selector [String]
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
end
