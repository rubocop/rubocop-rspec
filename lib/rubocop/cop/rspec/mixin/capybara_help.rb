# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Help methods for capybara.
      module CapybaraHelp
        module_function

        # @param node [RuboCop::AST::SendNode]
        # @param locator [String]
        # @param element [String]
        # @return [Boolean]
        def specific_option?(node, locator, element)
          attrs = CssSelector.attributes(locator).keys
          return false unless replaceable_element?(node, element, attrs)

          attrs.all? do |attr|
            CssSelector.specific_options?(element, attr)
          end
        end

        # @param locator [String]
        # @return [Boolean]
        def specific_pseudo_classes?(locator)
          CssSelector.pseudo_classes(locator).all? do |pseudo_class|
            replaceable_pseudo_class?(pseudo_class, locator)
          end
        end

        # @param pseudo_class [String]
        # @param locator [String]
        # @return [Boolean]
        def replaceable_pseudo_class?(pseudo_class, locator)
          return false unless CssSelector.specific_pesudo_classes?(pseudo_class)

          case pseudo_class
          when 'not()' then replaceable_pseudo_class_not?(locator)
          else true
          end
        end

        # @param locator [String]
        # @return [Boolean]
        def replaceable_pseudo_class_not?(locator)
          locator.scan(/not\(.*?\)/).all? do |negation|
            CssSelector.attributes(negation).values.all? do |v|
              v.is_a?(TrueClass) || v.is_a?(FalseClass)
            end
          end
        end

        # @param node [RuboCop::AST::SendNode]
        # @param element [String]
        # @param attrs [Array<String>]
        # @return [Boolean]
        def replaceable_element?(node, element, attrs)
          case element
          when 'link' then replaceable_to_link?(node, attrs)
          else true
          end
        end

        # @param node [RuboCop::AST::SendNode]
        # @param attrs [Array<String>]
        # @return [Boolean]
        def replaceable_to_link?(node, attrs)
          include_option?(node, :href) || attrs.include?('href')
        end

        # @param node [RuboCop::AST::SendNode]
        # @param option [Symbol]
        # @return [Boolean]
        def include_option?(node, option)
          node.each_descendant(:sym).find { |opt| opt.value == option }
        end
      end
    end
  end
end
