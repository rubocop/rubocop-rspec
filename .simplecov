# frozen_string_literal: true

SimpleCov.enable_coverage :branch
SimpleCov.minimum_coverage line: 100, branch: 100
SimpleCov.ignore_branches :implicit_else
SimpleCov.skip '/spec/'
SimpleCov.skip '/vendor/bundle/'
