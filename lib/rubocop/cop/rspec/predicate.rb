# encoding: utf-8

module RuboCop
  module Cop
    module RSpec
      # Prefer using predicate matcher instead of truthiness
      #
      # @example
      #   # bad
      #     expect(foo.valid?).to be_truthy
      #
      #   # good
      #     expect(foo).to be_valid
      class Predicate < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use predicate matcher `%s`'.freeze

        def on_send(node)
          expectation = correction(node)
          return if expectation.nil?

          add_offense(
            node,
            :expression,
            format(MSG, expectation)
          )
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, correction(node))
          end
        end

        private

        def requires_predicate?
          style == :predicate
        end

        def correction(node)
          if requires_predicate?
            PredicateCorrector.new(node, style).correction
          else
            BooleanCorrector.new(node, style).correction
          end
        end
      end

      # Corrector base class for offense detection
      class Corrector
        attr_reader :node, :style, :object, :args, :action

        def initialize(node, style)
          @node = node
          @style = style

          receiver, @action, @args = *node
          _, _, @object = *receiver
        end

        def correction
          return unless correctable?

          node.source
            .gsub(object.source, expectation)
            .gsub(args.source, matcher)
            .gsub(".#{action}", actionable)
        end

        def correctable?
          return false unless object
          return false unless args
          return false if args.source =~ /^(be_truthy|be_falsey)$/
          return false unless expectation
          return false unless matcher

          true
        end
      end

      # Corrector for the predicate style
      class PredicateCorrector < Corrector
        private

        def actionable
          if args.source.include?('false')
            '.not_to'
          else
            '.to'
          end
        end

        def expectation
          return unless object
          children = object.children.first

          return unless children.is_a?(RuboCop::Node)
          children.source
        end

        def matcher
          method = object.method_name.to_s
          return unless method.delete!('?')

          matcher = matcher_for_method(method)

          method_args = object.method_args.map(&:source).join(', ')
          matcher += "(#{method_args})" unless method_args.empty?

          matcher
        end

        # rubocop:disable Metrics/MethodLength
        def matcher_for_method(method)
          case method
          when /^(respond_to|include)$/
            method
          when /^(is_a|kind_of)$/
            'be_a'
          when /^(has_key|key)$/
            'have_key'
          when /^(has_)\w+/
            method.gsub('has', 'have')
          else
            "be_#{method}"
          end
        end
        # rubocop:enable Metrics/MethodLength
      end

      # Corrector for boolean and truthiness style
      class BooleanCorrector < Corrector
        private

        def requires_truthiness?
          style == :truthiness
        end

        def actionable
          '.to'
        end

        def expectation
          return unless args
          matcher = args.method_name.to_s
          method_args = args.method_args.map(&:source).join(', ')

          method = "#{object.source}.#{method_for_matcher(matcher)}?"
          method += "(#{method_args})" unless method_args.empty?
          method
        end

        # rubocop:disable Metrics/MethodLength
        def method_for_matcher(matcher)
          case matcher
          when 'respond_to'
            matcher
          when 'be_a'
            'is_a'
          when 'have_key'
            'key'
          when /^(have_)\w+/
            matcher.gsub('have', 'has')
          else
            matcher.gsub('be_', '')
          end
        end
        # rubocop:enable Metrics/MethodLength

        def matcher
          if action == :to
            requires_truthiness? ? 'be_truthy' : 'eq(true)'
          else
            requires_truthiness? ? 'be_falsey' : 'eq(false)'
          end
        end
      end
    end
  end
end
