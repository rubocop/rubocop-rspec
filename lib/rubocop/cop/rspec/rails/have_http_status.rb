# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Checks that tests use `have_http_status` instead of equality matchers.
        #
        # @example
        #   # bad
        #   expect(response.status).to be(200)
        #
        #   # good
        #   expect(response).to have_http_status(200)
        #
        class HaveHttpStatus < Base
          extend AutoCorrector

          MSG =
            'Prefer `expect(response).%<to>s have_http_status(%<status>i)` ' \
            'over `expect(response.status).%<to>s %<match>s`.'

          # @!method match_status(node)
          def_node_matcher :match_status, <<-PATTERN
            (send
              (send nil? :expect
                $(send (send nil? :response) :status)
              )
              $#Runners.all
              $(send nil? {:be :eq :eql :equal} (int $_))
            )
          PATTERN

          def on_send(node)
            match_status(node) do |response_status, to, match, status|
              message = format(MSG, to: to, match: match.source, status: status)
              add_offense(node, message: message) do |corrector|
                corrector.replace(response_status.source_range, 'response')
                corrector.replace(match.loc.selector, 'have_http_status')
              end
            end
          end
        end
      end
    end
  end
end
