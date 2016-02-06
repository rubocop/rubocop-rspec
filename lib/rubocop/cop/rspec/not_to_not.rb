# encoding: utf-8

module RuboCop
  module Cop
    module RSpec
      # Enforces the usage of the same method on all negative message
      # expectations.
      #
      # @example
      #   # bad
      #   it '...' do
      #     expect(false).to_not be_true
      #   end
      #
      #   # good
      #   it '...' do
      #     expect(false).not_to be_true
      #   end
      class NotToNot < Cop
        ACCEPTED_METHODS = [:not_to, :to_not].freeze

        def on_send(node)
          _receiver, method_name, *_args = *node

          if method_name == rejected_method
            add_offense(node, :expression, offense_message)
          end
        end

        private

        def accepted_method
          @accepted_method ||= begin
            method = cop_config['AcceptedMethod'].to_sym

            unless ACCEPTED_METHODS.include?(method)
              raise "Invalid AcceptedMethod value: #{method}"
            end

            method
          end
        end

        def rejected_method
          @rejected_method ||= (ACCEPTED_METHODS - [accepted_method]).first
        end

        def offense_message
          "Use `#{accepted_method}` instead of `#{rejected_method}`"
        end
      end
    end
  end
end
