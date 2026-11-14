# frozen_string_literal: true

SimpleCov.configure do
  enable_coverage :branch
  coverage :line, minimum: 100
  coverage :branch, minimum: 100, ignore: :implicit_else
  skip ['/spec/', '/vendor/bundle/']
end
