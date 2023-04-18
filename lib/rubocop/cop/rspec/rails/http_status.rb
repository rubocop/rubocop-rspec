# frozen_string_literal: true

require 'rack/utils'

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Enforces use of symbolic or numeric value to describe HTTP status.
        #
        # This cop inspects only `have_http_status` calls.
        # So, this cop does not check if a method starting with `be_*` is used
        # when setting for `EnforcedStyle: symbolic` or
        # `EnforcedStyle: numeric`.
        #
        # @example `EnforcedStyle: symbolic` (default)
        #   # bad
        #   it { is_expected.to have_http_status 200 }
        #   it { is_expected.to have_http_status 404 }
        #
        #   # good
        #   it { is_expected.to have_http_status :ok }
        #   it { is_expected.to have_http_status :not_found }
        #   it { is_expected.to have_http_status :success }
        #   it { is_expected.to have_http_status :error }
        #
        # @example `EnforcedStyle: numeric`
        #   # bad
        #   it { is_expected.to have_http_status :ok }
        #   it { is_expected.to have_http_status :not_found }
        #
        #   # good
        #   it { is_expected.to have_http_status 200 }
        #   it { is_expected.to have_http_status 404 }
        #   it { is_expected.to have_http_status :success }
        #   it { is_expected.to have_http_status :error }
        #
        # @example `EnforcedStyle: be_status`
        #   # bad
        #   it { is_expected.to have_http_status :ok }
        #   it { is_expected.to have_http_status :not_found }
        #   it { is_expected.to have_http_status 200 }
        #   it { is_expected.to have_http_status 404 }
        #
        #   # good
        #   it { is_expected.to be_ok }
        #   it { is_expected.to be_not_found }
        #   it { is_expected.to have_http_status :success }
        #   it { is_expected.to have_http_status :error }
        #
        class HttpStatus < Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle
          RESTRICT_ON_SEND = %i[have_http_status].freeze

          # @!method http_status(node)
          def_node_matcher :http_status, <<-PATTERN
            (send nil? :have_http_status ${int sym})
          PATTERN

          def on_send(node)
            http_status(node) do |arg|
              checker = checker_class.new(arg)
              return unless checker.offensive?

              add_offense(checker.offense_range,
                          message: checker.message) do |corrector|
                corrector.replace(checker.offense_range, checker.prefer)
              end
            end
          end

          private

          def checker_class
            case style
            when :symbolic
              SymbolicStyleChecker
            when :numeric
              NumericStyleChecker
            when :be_status
              BeStatusStyleChecker
            end
          end

          # :nodoc:
          class StyleCheckerBase
            MSG = 'Prefer `%<prefer>s` over `%<current>s` ' \
                  'to describe HTTP status code.'
            ALLOWED_STATUSES = %i[error success missing redirect].freeze

            attr_reader :node

            def initialize(node)
              @node = node
            end

            def message
              format(MSG, prefer: prefer, current: current)
            end

            def offense_range
              node
            end

            def allowed_symbol?
              node.sym_type? && ALLOWED_STATUSES.include?(node.value)
            end

            def custom_http_status_code?
              node.int_type? &&
                !::Rack::Utils::SYMBOL_TO_STATUS_CODE.value?(node.source.to_i)
            end
          end

          # :nodoc:
          class SymbolicStyleChecker < StyleCheckerBase
            def offensive?
              !node.sym_type? && !custom_http_status_code?
            end

            def prefer
              symbol.inspect
            end

            def current
              number.inspect
            end

            private

            def symbol
              ::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(number)
            end

            def number
              node.source.to_i
            end
          end

          # :nodoc:
          class NumericStyleChecker < StyleCheckerBase
            def offensive?
              !node.int_type? && !allowed_symbol?
            end

            def prefer
              number.to_s
            end

            def current
              symbol.inspect
            end

            private

            def symbol
              node.value
            end

            def number
              ::Rack::Utils::SYMBOL_TO_STATUS_CODE[symbol]
            end
          end

          # :nodoc:
          class BeStatusStyleChecker < StyleCheckerBase
            def offensive?
              (!node.sym_type? && !custom_http_status_code?) ||
                (!node.int_type? && !allowed_symbol?)
            end

            def offense_range
              node.parent
            end

            def prefer
              if node.sym_type?
                "be_#{node.value}"
              else
                "be_#{symbol}"
              end
            end

            def current
              offense_range.source
            end

            private

            def symbol
              ::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(number)
            end

            def number
              node.source.to_i
            end
          end
        end
      end
    end
  end
end
