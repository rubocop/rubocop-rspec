# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Checks for create_list usage.
        #
        # This cop can be configured using the `EnforcedStyle` option
        #
        # @example `EnforcedStyle: create_list` (default)
        #   # bad
        #   3.times { create :user }
        #
        #   # good
        #   create_list :user, 3
        #
        #   # bad
        #   3.times { create :user, age: 18 }
        #
        #   # good - index is used to alter the created models attributes
        #   3.times { |n| create :user, age: n }
        #
        #   # good - contains a method call, may return different values
        #   3.times { create :user, age: rand }
        #
        # @example `EnforcedStyle: n_times`
        #   # bad
        #   create_list :user, 3
        #
        #   # good
        #   3.times { create :user }
        #
        class CreateList < ::RuboCop::Cop::Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle
          include RuboCop::RSpec::FactoryBot::Language

          MSG_CREATE_LIST = 'Prefer create_list.'
          MSG_N_TIMES = 'Prefer %<number>s.times.'
          RESTRICT_ON_SEND = %i[create_list].freeze

          # @!method array_new_or_n_times_block?(node)
          def_node_matcher :array_new_or_n_times_block?, <<-PATTERN
            (block
              {
                (send (const {nil? | cbase} :Array) :new (int _)) |
                (send (int _) :times)
              }
              ...
            )
          PATTERN

          # @!method block_with_arg_and_used?(node)
          def_node_matcher :block_with_arg_and_used?, <<-PATTERN
            (block
              _
              (args (arg _value))
              `_value
            )
          PATTERN

          # @!method arguments_include_method_call?(node)
          def_node_matcher :arguments_include_method_call?, <<-PATTERN
            (send ${nil? #factory_bot?} :create (sym $_) `$(send ...))
          PATTERN

          # @!method factory_call(node)
          def_node_matcher :factory_call, <<-PATTERN
            (send ${nil? #factory_bot?} :create (sym $_) $...)
          PATTERN

          # @!method factory_list_call(node)
          def_node_matcher :factory_list_call, <<-PATTERN
            (send {nil? #factory_bot?} :create_list (sym _) (int $_) ...)
          PATTERN

          def on_block(node) # rubocop:todo InternalAffairs/NumblockHandler
            return unless style == :create_list

            return unless array_new_or_n_times_block?(node)
            return if block_with_arg_and_used?(node)
            return unless node.body
            return if arguments_include_method_call?(node.body)
            return unless contains_only_factory?(node.body)

            add_offense(node.send_node, message: MSG_CREATE_LIST) do |corrector|
              CreateListCorrector.new(node.send_node).call(corrector)
            end
          end

          def on_send(node)
            return unless style == :n_times

            factory_list_call(node) do |count|
              message = format(MSG_N_TIMES, number: count)
              add_offense(node.loc.selector, message: message) do |corrector|
                TimesCorrector.new(node).call(corrector)
              end
            end
          end

          private

          def contains_only_factory?(node)
            if node.block_type?
              factory_call(node.send_node)
            else
              factory_call(node)
            end
          end

          # :nodoc
          module Corrector
            private

            def build_options_string(options)
              options.map(&:source).join(', ')
            end

            def format_method_call(node, method, arguments)
              if node.block_type? || node.parenthesized?
                "#{method}(#{arguments})"
              else
                "#{method} #{arguments}"
              end
            end

            def format_receiver(receiver)
              return '' unless receiver

              "#{receiver.source}."
            end
          end

          # :nodoc
          class TimesCorrector
            include Corrector

            def initialize(node)
              @node = node
            end

            def call(corrector)
              replacement = generate_n_times_block(node)
              corrector.replace(node.block_node || node, replacement)
            end

            private

            attr_reader :node

            def generate_n_times_block(node)
              factory, count, *options = node.arguments

              arguments = factory.source
              options = build_options_string(options)
              arguments += ", #{options}" unless options.empty?

              replacement = format_receiver(node.receiver)
              replacement += format_method_call(node, 'create', arguments)
              replacement += " #{factory_call_block_source}" if node.block_node
              "#{count.source}.times { #{replacement} }"
            end

            def factory_call_block_source
              node.block_node.location.begin.with(
                end_pos: node.block_node.location.end.end_pos
              ).source
            end
          end

          # :nodoc:
          class CreateListCorrector
            include Corrector

            def initialize(node)
              @node = node.parent
            end

            def call(corrector)
              replacement = if node.body.block_type?
                              call_with_block_replacement(node)
                            else
                              call_replacement(node)
                            end

              corrector.replace(node, replacement)
            end

            private

            attr_reader :node

            def call_with_block_replacement(node)
              block = node.body
              arguments = build_arguments(block, count_from(node))
              replacement = format_receiver(block.receiver)
              replacement += format_method_call(block, 'create_list', arguments)
              replacement += format_block(block)
              replacement
            end

            def build_arguments(node, count)
              factory, *options = *node.send_node.arguments

              arguments = ":#{factory.value}, #{count}"
              options = build_options_string(options)
              arguments += ", #{options}" unless options.empty?
              arguments
            end

            def call_replacement(node)
              block = node.body
              factory, *options = *block.arguments

              arguments = "#{factory.source}, #{count_from(node)}"
              options = build_options_string(options)
              arguments += ", #{options}" unless options.empty?

              replacement = format_receiver(block.receiver)
              replacement += format_method_call(block, 'create_list', arguments)
              replacement
            end

            def count_from(node)
              count_node =
                if node.receiver.int_type?
                  node.receiver
                else
                  node.send_node.first_argument
                end
              count_node.source
            end

            def format_block(node)
              if node.body.begin_type?
                format_multiline_block(node)
              else
                format_singleline_block(node)
              end
            end

            def format_multiline_block(node)
              indent = ' ' * node.body.loc.column
              indent_end = ' ' * node.parent.loc.column
              " do #{node.arguments.source}\n" \
                "#{indent}#{node.body.source}\n" \
                "#{indent_end}end"
            end

            def format_singleline_block(node)
              " { #{node.arguments.source} #{node.body.source} }"
            end
          end
        end
      end
    end
  end
end
