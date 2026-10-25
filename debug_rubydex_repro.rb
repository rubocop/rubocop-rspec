# frozen_string_literal: true

# Temporary debugging script, not meant to be merged.
# Reproduces bogus `deprecated?` flags from rubydex on ruby-head without
# involving RuboCop. Exit 1 if any non-deprecated constant is flagged.

require 'rubydex'

failures = []

# Part 1: tiny in-memory fixture.
graph = Rubydex::Graph.new
graph.index_source('file:///fixture.rb', <<~RUBY, 'ruby')
  module Fixture
    # @deprecated Use NEW_CONST instead.
    OLD_CONST = 1

    # Just a normal comment.
    NEW_CONST = 2

    PLAIN_CONST = 3
  end
RUBY
graph.resolve

ns = graph['Fixture']
{
  'OLD_CONST' => true,
  'NEW_CONST' => false,
  'PLAIN_CONST' => false
}.each do |name, expected|
  decl = ns&.member(name)
  defs = decl ? decl.definitions.map(&:deprecated?) : []
  ok = !defs.empty? && defs.all? == expected
  failures << name unless ok
  puts format('%<name>s: deprecated?=%<defs>p comments=%<comments>p (%<status>s)',
              name: name,
              defs: defs,
              comments: decl ? decl.definitions.flat_map { |d| d.comments.map(&:string) } : [],
              status: ok ? 'ok' : "UNEXPECTED, wanted #{expected}")
end

# Part 2: this repo's own lib, mirroring the scale of the real failure.
graph2 = Rubydex::Graph.new
graph2.index_all(Dir['lib/**/*.rb'].map { |f| File.expand_path(f) })
graph2.resolve

PART2 = {
  'RuboCop::Cop::RSpec::ExampleWording' => 'SHOULD_PREFIX',
  'RuboCop::Cop::RSpec::ChangeByZero' => 'CHANGE_METHODS',
  'RuboCop::RSpec::Wording' => 'WONT_PREFIX'
}.freeze

def check(graph, failures)
  PART2.each do |namespace, name|
    decl = graph[namespace]&.member(name)
    defs = decl ? decl.definitions.map(&:deprecated?) : []
    comments = decl ? decl.definitions.flat_map { |d| d.comments.map(&:string) } : []
    ok = !defs.empty? && defs.none?
    failures << "#{namespace}::#{name}" unless ok
    puts format('%<name>s::%<const>s: deprecated?=%<defs>p comments=%<comments>p (%<status>s)',
                name: namespace, const: name, defs: defs, comments: comments,
                status: ok ? 'ok' : 'UNEXPECTED, wanted all false')
  end
end

check(graph2, failures)

# Part 3: force GC pressure and re-query. If flags flip after GC.compact,
# the graph (or its Ruby wrapper) is not surviving garbage collection.
puts '--- after GC.start + GC.compact ---'
GC.start
GC.compact
check(graph2, failures)

if failures.empty?
  puts 'ALL OK'
else
  puts "FAILURES: #{failures.join(', ')}"
  exit 1
end
