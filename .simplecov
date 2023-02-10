# frozen_string_literal: true

SimpleCov.start do
  enable_coverage :branch
  minimum_coverage line: 99.60, branch: 95.32
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
end
