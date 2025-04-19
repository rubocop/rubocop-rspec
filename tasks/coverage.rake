# frozen_string_literal: true

namespace :coverage do
  desc 'Report Coverage from merged CI runs'
  task :ci do
    require 'simplecov'

    SimpleCov.collate Dir['coverage-*/.resultset.json']
  end
end
