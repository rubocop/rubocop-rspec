# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Checks for name style for argument of FactoryBot::Syntax::Methods.
        #
        # @example EnforcedStyle: symbol (default)
        #   # bad
        #   create('user')
        #   build "user", username: "NAME"
        #
        #   # good
        #   create(:user)
        #   build :user, username: "NAME"
        #
        # @example EnforcedStyle: string
        #   # bad
        #   create(:user)
        #   build :user, username: "NAME"
        #
        #   # good
        #   create('user')
        #   build "user", username: "NAME"
        #
        class FactoryNameStyle < ::RuboCop::Cop::Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle
          include RuboCop::RSpec::FactoryBot::Language

          MSG = 'Use %<prefer>s to refer to a factory.'
          FACTORY_CALLS = RuboCop::RSpec::FactoryBot::Language::METHODS
          RESTRICT_ON_SEND = FACTORY_CALLS

          # @!method factory_call(node)
          def_node_matcher :factory_call, <<-PATTERN
          (send
            {#factory_bot? nil?} %FACTORY_CALLS
            ${str sym} ...
          )
          PATTERN

          def on_send(node)
            factory_call(node) do |name|
              if offense_for_symbol_style?(name)
                register_offense(name, name.value.to_sym.inspect)
              elsif offense_for_string_style?(name)
                register_offense(name, name.value.to_s.inspect)
              end
            end
          end

          private

          def offense_for_symbol_style?(name)
            name.str_type? && style == :symbol
          end

          def offense_for_string_style?(name)
            name.sym_type? && style == :string
          end

          def register_offense(name, prefer)
            add_offense(name,
                        message: format(MSG, prefer: style.to_s)) do |corrector|
              corrector.replace(name, prefer)
            end
          end
        end
      end
    end
  end
end
