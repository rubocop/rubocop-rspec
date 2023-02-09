# frozen_string_literal: true

SimpleCov.start do
  enable_coverage :branch
  minimum_coverage line: 99.83, branch: 95.33
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
end
