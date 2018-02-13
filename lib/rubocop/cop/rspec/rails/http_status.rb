# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Enforces use of symbolic or numeric value to describe HTTP status.
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
        class HttpStatus < Cop
          begin
            require 'rack/utils'
            RACK_LOADED = true
          rescue LoadError
            RACK_LOADED = false
          end

          include ConfigurableEnforcedStyle

          MSG = 'Prefer `%<prefer>s` over `%<current>s` '\
                'to describe HTTP status code.'.freeze
          WHITELIST_STATUS = %i[error success missing redirect].freeze

          def_node_matcher :http_status, <<-PATTERN
            (send nil? :have_http_status ${int sym})
          PATTERN

          def on_send(node) # rubocop:disable Metrics/CyclomaticComplexity
            http_status(node) do |ast_node|
              if style == :numeric
                return if ast_node.int_type?
                return if ast_node.sym_type? &&
                    WHITELIST_STATUS.include?(ast_node.value)
              end

              return if style == :symbolic && ast_node.sym_type?

              add_offense(ast_node)
            end
          end

          def message(node)
            prefer, current = message_without_autocorrect unless RACK_LOADED
            prefer, current = message_for_autocorrect(node) if RACK_LOADED

            format(MSG, prefer: prefer, current: current)
          end

          def support_autocorrect?
            RACK_LOADED
          end

          def autocorrect(node)
            replacement = new_value(node)
            return if replacement.nil?

            lambda do |corrector|
              corrector.replace(node.loc.expression, replacement.to_s)
            end
          end

          private

          def new_value(node)
            case style
            when :numeric
              numeric, = symbolic_to_numeric_value(node)
              numeric
            when :symbolic
              symbol, = numeric_to_symbolic_value(node)
              symbol
            end
          end

          def numeric_to_symbolic_value(node)
            numeric = node.source.to_i
            symbol = ":#{::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(numeric)}"

            [symbol, numeric]
          end

          def symbolic_to_numeric_value(node)
            symbol = node.value
            numeric = ::Rack::Utils::SYMBOL_TO_STATUS_CODE[symbol]

            [numeric, symbol]
          end

          def message_for_autocorrect(node)
            if style == :numeric
              prefer, current = symbolic_to_numeric_value(node)
              return [prefer, ":#{current}"]
            end

            numeric_to_symbolic_value(node)
          end

          def message_without_autocorrect
            return %i[numeric symbolic] if style == :numeric

            %i[symbolic numeric]
          end
        end
      end
    end
  end
end
