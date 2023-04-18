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
        #   expect(response.code).to eq("200")
        #
        #   # good
        #   expect(response).to have_http_status(200)
        #
        class HaveHttpStatus < ::RuboCop::Cop::Base
          extend AutoCorrector

          MSG =
            'Prefer `expect(response).%<to>s have_http_status(%<status>i)` ' \
            'over `%<bad_code>s`.'

          RUNNERS = %i[to to_not not_to].to_set
          RESTRICT_ON_SEND = RUNNERS

          # @!method match_status(node)
          def_node_matcher :match_status, <<-PATTERN
            (send
              (send nil? :expect
                $(send (send nil? :response) {:status :code})
              )
              $RUNNERS
              $(send nil? {:be :eq :eql :equal} ({int str} $_))
            )
          PATTERN

          def on_send(node)
            match_status(node) do |response_status, to, match, status|
              message = format(MSG, to: to, status: status,
                                    bad_code: node.source)
              add_offense(node, message: message) do |corrector|
                corrector.replace(response_status, 'response')
                corrector.replace(match.loc.selector, 'have_http_status')
                corrector.replace(match.first_argument, status.to_i.to_s)
              end
            end
          end
        end
      end
    end
  end
end
