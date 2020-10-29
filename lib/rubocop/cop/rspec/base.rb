# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # @abstract parent class to RSpec cops
      class Base < ::RuboCop::Cop::Base
        include RuboCop::RSpec::Language
        include RuboCop::RSpec::Language::NodePattern

        exclude_from_registry

        # Invoke the original inherited hook so our cops are recognized
        def self.inherited(subclass) # rubocop:disable Lint/MissingSuper
          RuboCop::Cop::Base.inherited(subclass)
        end
      end
    end
  end
end
