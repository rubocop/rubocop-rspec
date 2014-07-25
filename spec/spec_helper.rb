# encoding: utf-8

# As much as possible, we try to reuse RuboCop's spec environment.
require File.join(
  Gem::Specification.find_by_name('rubocop').gem_dir, 'spec', 'spec_helper.rb'
)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubocop-rspec'
