# frozen_string_literal: true

# Helpers for examples tagged with `:project_index`. The `before` hook skips
# the example when the project-index gem cannot be loaded for the current Ruby;
# the included module builds an in-memory index from a `uri => source` hash so
# that index-aware cop logic can be exercised directly.
module ProjectIndexSpecHelpers
  def build_index(sources)
    graph = Rubydex::Graph.new
    sources.each { |uri, source| graph.index_source(uri, source, 'ruby') }
    graph.resolve
    graph
  end
end

RSpec.configure do |config|
  config.include ProjectIndexSpecHelpers, :project_index

  config.before(:each, :project_index) do
    unless RuboCop::ProjectIndexLoader.available?
      minimum = RuboCop::ProjectIndexLoader::MINIMUM_RUBY_VERSION
      reason = if RuboCop::ProjectIndexLoader.supported_ruby?
                 'rubydex gem is not installed.'
               else
                 "rubydex requires Ruby #{minimum} or later."
               end
      skip reason
    end
  end
end
