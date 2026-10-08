# frozen_string_literal: true

module RuboCop
  module RSpec
    # Contains node matchers for common RSpec DSL.
    #
    # RSpec allows for configuring aliases for commonly used DSL elements, e.g.
    # example groups and hooks. It is possible to configure RuboCop RSpec to
    # be able to properly detect these elements in the `RSpec/Language` section
    # of the RuboCop YAML configuration file.
    #
    # In addition to providing useful matchers, this class is responsible for
    # using the configured aliases.
    module Language
      extend RuboCop::NodePattern::Macros

      class << self
        attr_reader :config

        def config=(config)
          @sets = nil unless config.equal?(@config)
          @config = config
        end

        # Checks membership in a configured list of method names, caching each
        # list as a Set of symbols to avoid per-call String allocations.
        def configured?(element, *path)
          element = element.to_sym if element.is_a?(String)
          list = config.dig(*path)
          @sets ||= {}.compare_by_identity
          (@sets[list] ||= list.to_set(&:to_sym)).include?(element)
        end
      end

      # @!method rspec?(node)
      def_node_matcher :rspec?, '{#explicit_rspec? nil?}'

      # @!method explicit_rspec?(node)
      def_node_matcher :explicit_rspec?, '(const {nil? cbase} :RSpec)'

      # @!method example_group?(node)
      def_node_matcher :example_group?, <<~PATTERN
        (any_block (send #rspec? #ExampleGroups.all ...) ...)
      PATTERN

      # @!method shared_group?(node)
      def_node_matcher :shared_group?,
                       '(block (send #rspec? #SharedGroups.all ...) ...)'

      # @!method spec_group?(node)
      def_node_matcher :spec_group?, <<~PATTERN
        (any_block (send #rspec?
             {#SharedGroups.all #ExampleGroups.all}
          ...) ...)
      PATTERN

      # @!method example_group_with_body?(node)
      def_node_matcher :example_group_with_body?, <<~PATTERN
        (block (send #rspec? #ExampleGroups.all ...) args !nil?)
      PATTERN

      # @!method example?(node)
      def_node_matcher :example?, '(block (send nil? #Examples.all ...) ...)'

      # @!method hook?(node)
      def_node_matcher :hook?, <<~PATTERN
        (any_block (send nil? #Hooks.all ...) ...)
      PATTERN

      # @!method let?(node)
      def_node_matcher :let?, <<~PATTERN
        {
          (block (send nil? #Helpers.all ...) ...)
          (send nil? #Helpers.all _ block_pass)
        }
      PATTERN

      # @!method include?(node)
      def_node_matcher :include?, <<~PATTERN
        {
          (block (send nil? #Includes.all ...) ...)
          (send nil? #Includes.all ...)
        }
      PATTERN

      # @!method subject?(node)
      def_node_matcher :subject?, '(block (send nil? #Subjects.all ...) ...)'

      # rubocop:disable Naming/PredicateMethod
      module ErrorMatchers # :nodoc:
        def self.all(element)
          Language.configured?(element, 'ErrorMatchers')
        end
      end

      module ExampleGroups # :nodoc:
        class << self
          def all(element)
            regular(element) ||
              skipped(element) ||
              focused(element)
          end

          def regular(element)
            Language.configured?(element, 'ExampleGroups', 'Regular')
          end

          def focused(element)
            Language.configured?(element, 'ExampleGroups', 'Focused')
          end

          def skipped(element)
            Language.configured?(element, 'ExampleGroups', 'Skipped')
          end
        end
      end

      module Examples # :nodoc:
        class << self
          def all(element)
            regular(element) ||
              focused(element) ||
              skipped(element) ||
              pending(element)
          end

          def regular(element)
            Language.configured?(element, 'Examples', 'Regular')
          end

          def focused(element)
            Language.configured?(element, 'Examples', 'Focused')
          end

          def skipped(element)
            Language.configured?(element, 'Examples', 'Skipped')
          end

          def pending(element)
            Language.configured?(element, 'Examples', 'Pending')
          end
        end
      end

      module Expectations # :nodoc:
        def self.all(element)
          Language.configured?(element, 'Expectations')
        end
      end

      module Helpers # :nodoc:
        def self.all(element)
          Language.configured?(element, 'Helpers')
        end
      end

      module Hooks # :nodoc:
        def self.all(element)
          Language.configured?(element, 'Hooks')
        end
      end

      module HookScopes # :nodoc:
        ALL = %i[each example context all suite].freeze
        def self.all(element)
          ALL.include?(element)
        end
      end

      module Includes # :nodoc:
        class << self
          def all(element)
            examples(element) ||
              context(element)
          end

          def examples(element)
            Language.configured?(element, 'Includes', 'Examples')
          end

          def context(element)
            Language.configured?(element, 'Includes', 'Context')
          end
        end
      end

      module Runners # :nodoc:
        ALL = %i[to to_not not_to].freeze
        class << self
          def all(element = nil)
            return ALL if element.nil?

            ALL.include?(element)
          end
        end
      end

      module SharedGroups # :nodoc:
        class << self
          def all(element)
            examples(element) ||
              context(element)
          end

          def examples(element)
            Language.configured?(element, 'SharedGroups', 'Examples')
          end

          def context(element)
            Language.configured?(element, 'SharedGroups', 'Context')
          end
        end
      end

      module Subjects # :nodoc:
        def self.all(element)
          Language.configured?(element, 'Subjects')
        end
      end
      # rubocop:enable Naming/PredicateMethod

      # This is used in Dialect and DescribeClass cops to detect RSpec blocks.
      module ALL # :nodoc:
        CONCEPTS = [ErrorMatchers, ExampleGroups, Examples, Expectations,
                    Helpers, Hooks, Includes, Runners, SharedGroups,
                    Subjects].freeze

        def self.all(element)
          CONCEPTS.find { |concept| concept.all(element) }
        end
      end

      private_constant :ErrorMatchers, :ExampleGroups, :Examples, :Expectations,
                       :Hooks, :Includes, :Runners, :SharedGroups, :ALL
    end
  end
end
