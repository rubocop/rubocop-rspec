# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that before/after(:all) isn't being used
      # as they are not rolled back.
      # See https://relishapp.com/rspec/rspec-rails/docs/transactions
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     before(:all) { do_something }
      #     after(:all) { do_something_else }
      #   end
      #
      #   # good
      #   describe MyClass do
      #     before(:each) { do_something }
      #     after(:each) { do_something_else }
      #   end
      class BeforeAfterAll < Cop
        MESSAGE = 'Avoid the use of before/after(:all) '\
          'as they are not rolled back and may lead to database state '\
          'leaking between examples'.freeze

        BEFORE_AFTER_METHODS = [
          :before,
          :after
        ].freeze

        ALL_PAIR = s(:sym, :all)

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless BEFORE_AFTER_METHODS.include?(method_name)
          return unless args.include?(ALL_PAIR)

          add_offense(node, :expression, MESSAGE)
        end
      end
    end
  end
end
