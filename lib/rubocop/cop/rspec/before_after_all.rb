# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that before/after(:all) isn't being used.
      #
      # @example
      #   # bad
      #   #
      #   # Faster but risk of state leaking between examples
      #   #
      #   describe MyClass do
      #     before(:all) { Widget.create }
      #     after(:all) { Widget.delete_all }
      #   end
      #
      #   # good
      #   #
      #   # Slower but examples are properly isolated
      #   #
      #   describe MyClass do
      #     before(:each) { Widget.create }
      #     after(:each) { Widget.delete_all }
      #   end
      class BeforeAfterAll < Cop
        MESSAGE = 'Beware of using `before/after(:all)` as it may cause state '\
          'to leak between tests. If you are using rspec-rails, and '\
          '`use_transactional_fixtures` is enabled, then records created in '\
          '`before(:all)` are not rolled back.'.freeze

        BEFORE_AFTER_METHODS = [
          :before,
          :after
        ].freeze

        ALL_PAIR = s(:sym, :all)
        CONTEXT_PAIR = s(:sym, :context)

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless BEFORE_AFTER_METHODS.include?(method_name)
          return unless args.include?(ALL_PAIR) || args.include?(CONTEXT_PAIR)

          add_offense(node, :expression, MESSAGE)
        end
      end
    end
  end
end
