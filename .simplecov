# frozen_string_literal: true

SimpleCov.start do
  enable_coverage :branch
  minimum_coverage line: 100, branch: 97.94
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
end
