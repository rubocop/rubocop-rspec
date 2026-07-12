# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec # rubocop:disable Style/Documentation
      # Autoloads mixin modules included by cops. Mixins are autoloaded to
      # reduce the number of requires because they're used only when
      # the relevant cop class is loaded.
      autoload :CommentsHelp, "#{__dir__}/mixin/comments_help"
      autoload :EmptyLineSeparation, "#{__dir__}/mixin/empty_line_separation"
      autoload :FileHelp, "#{__dir__}/mixin/file_help"
      autoload :FinalEndLocation, "#{__dir__}/mixin/final_end_location"
      autoload :InsideExample, "#{__dir__}/mixin/inside_example"
      autoload :InsideExampleGroup, "#{__dir__}/mixin/inside_example_group"
      autoload :LocationHelp, "#{__dir__}/mixin/location_help"
      autoload :Metadata, "#{__dir__}/mixin/metadata"
      autoload :Namespace, "#{__dir__}/mixin/namespace"
      autoload :RepeatedItems, "#{__dir__}/mixin/repeated_items"
      autoload :SkipOrPending, "#{__dir__}/mixin/skip_or_pending"
      autoload :TopLevelGroup, "#{__dir__}/mixin/top_level_group"
      autoload :Variable, "#{__dir__}/mixin/variable"
    end
  end
end
