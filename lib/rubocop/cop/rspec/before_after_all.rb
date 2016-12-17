# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that before/after(:all) isn't being used.
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
        MESSAGE = 'Beware of using `before/after(:all)` as it may cause state '\
          'to leak between tests. If you are using rspec-rails, and '\
          '`use_transactional_fixtures` is enabled, then records created in '\
          '`before(:all)` are not rolled back.'

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
