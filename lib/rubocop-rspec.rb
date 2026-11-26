# frozen_string_literal: true

require 'pathname'
require 'yaml'

require 'rubocop'

require_relative 'rubocop/rspec'
require_relative 'rubocop/rspec/language'
require_relative 'rubocop/rspec/node'
require_relative 'rubocop/rspec/plugin'
require_relative 'rubocop/rspec/version'
require_relative 'rubocop/rspec/wording'

require_relative 'rubocop/cop/rspec/mixin'

require_relative 'rubocop/cop/rspec/base'
require_relative 'rubocop/rspec/align_let_brace'
require_relative 'rubocop/rspec/concept'
require_relative 'rubocop/rspec/corrector/move_node'
require_relative 'rubocop/rspec/example'
require_relative 'rubocop/rspec/example_group'
require_relative 'rubocop/rspec/hook'

require_relative 'rubocop/cop/rspec'

RuboCop::AST::Node.include(RuboCop::RSpec::Node)
