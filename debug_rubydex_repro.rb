# frozen_string_literal: true

# Temporary debugging script, not meant to be merged.
# Reproduces bogus `deprecated?` flags from rubydex on ruby-head without
# involving RuboCop. Exit 1 if any expectation fails.

require 'rubydex'
require 'tmpdir'

failures = []

FIXTURE = <<~RUBY
  module Fixture
    INT_CONST = 3
    STR_CONST = 'x'.freeze
    REGEX_CONST = /foo/i.freeze
    ARRAY_CONST = %i[a b].freeze
    SET_CONST = Set[:a].freeze
    PATH_CONST = Pathname.new(__dir__)

    # @deprecated Use INT_CONST instead.
    OLD_REGEX = /old/.freeze
  end
RUBY

EXPECTED = {
  'INT_CONST' => false,
  'STR_CONST' => false,
  'REGEX_CONST' => false,
  'ARRAY_CONST' => false,
  'SET_CONST' => false,
  'PATH_CONST' => false,
  'OLD_REGEX' => true
}.freeze

def check_constants(graph, namespace, expected, failures)
  ns = graph[namespace]
  expected.each do |name, want|
    decl = ns&.member(name)
    defs = decl ? decl.definitions : []
    flags = defs.map(&:deprecated?)
    lines = defs.map { |d| d.location&.start_line }
    ok = !flags.empty? && flags.all? == want
    failures << "#{namespace}::#{name}" unless ok
    puts format('  %<name>s: deprecated?=%<flags>p lines=%<lines>p comments=%<comments>p (%<status>s)',
                name: name, flags: flags, lines: lines,
                comments: defs.flat_map { |d| d.comments.map(&:string) },
                status: ok ? 'ok' : "UNEXPECTED, wanted #{want}")
  end
end

# Part 1: typed constants from an in-memory source.
puts '--- part 1: index_source, typed constants ---'
graph = Rubydex::Graph.new
graph.index_source('file:///fixture.rb', FIXTURE, 'ruby')
graph.resolve
check_constants(graph, 'Fixture', EXPECTED, failures)

# Part 2: the same fixture read from disk via index_all.
puts '--- part 2: index_all, same fixture on disk ---'
Dir.mktmpdir do |dir|
  path = File.join(dir, 'fixture.rb')
  File.write(path, FIXTURE)
  graph = Rubydex::Graph.new
  graph.index_all([path])
  graph.resolve
  check_constants(graph, 'Fixture', EXPECTED, failures)
end

# Part 3: this repo's own lib, mirroring the scale of the real failure.
puts '--- part 3: repo lib ---'
graph2 = Rubydex::Graph.new
graph2.index_all(Dir['lib/**/*.rb'].map { |f| File.expand_path(f) })
graph2.resolve

part3 = {
  'RuboCop::Cop::RSpec::ExampleWording' => 'SHOULD_PREFIX',
  'RuboCop::Cop::RSpec::ChangeByZero' => 'CHANGE_METHODS',
  'RuboCop::RSpec::Wording' => 'WONT_PREFIX'
}.freeze
part3.each do |namespace, name|
  decl = graph2[namespace]&.member(name)
  defs = decl ? decl.definitions : []
  flags = defs.map(&:deprecated?)
  lines = defs.map { |d| d.location&.start_line }
  ok = !flags.empty? && flags.none?
  failures << "#{namespace}::#{name}" unless ok
  puts format('  %<name>s::%<const>s: deprecated?=%<flags>p lines=%<lines>p comments=%<comments>p (%<status>s)',
              name: namespace, const: name, flags: flags, lines: lines,
              comments: defs.flat_map { |d| d.comments.map(&:string) },
              status: ok ? 'ok' : 'UNEXPECTED, wanted all false')
end

puts '--- part 4: re-query after GC.start + GC.compact ---'
GC.start
GC.compact
part3.each do |namespace, name|
  decl = graph2[namespace]&.member(name)
  flags = decl ? decl.definitions.map(&:deprecated?) : []
  puts format('  %<name>s::%<const>s: deprecated?=%<flags>p',
              name: namespace, const: name, flags: flags)
end

if failures.empty?
  puts 'ALL OK'
else
  puts "FAILURES: #{failures.uniq.join(', ')}"
  exit 1
end
