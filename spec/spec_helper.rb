# encoding: utf-8

# As much as possible, we try to reuse RuboCop's spec environment.
require File.join(
  Gem::Specification.find_by_name('rubocop').gem_dir, 'spec', 'spec_helper.rb'
)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubocop-rspec'

# Overwriting RuboCop's parse_source to add support for mocked file paths.
#
# Remove once rubocop > 0.17.0 releases.
def parse_source(source, file = nil)
  source = source.join($RS) if source.is_a?(Array)
  if file.is_a? String
    Rubocop::SourceParser.parse(source, file)
  elsif file
    file.write(source)
    file.rewind
    Rubocop::SourceParser.parse(source, file.path)
  else
    Rubocop::SourceParser.parse(source)
  end
end
