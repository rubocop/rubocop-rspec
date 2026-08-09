# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks whether a node could be referenced from shared code (a
      # `shared_context`/`shared_examples` block, or code that includes one)
      # that frequently lives in another file, and consults the project-wide
      # index to resolve such cross-file references.
      module SharedCodeReference
        extend NodePattern::Macros

        include RuboCop::RSpec::Language
        include ProjectIndexHelp

        def self.included(klass)
          klass.class_eval do
            class << self
              # The reference-name set is a property of the index, not of
              # the cop instance, so all per-file instances share one
              # computation. A single-entry cache (instead of a hash keyed
              # by index) avoids retaining stale graphs in long-lived
              # processes.
              attr_accessor :cached_reference_names
            end
          end
        end

        private

        # @!method shared_group_or_including?(node)
        def_node_matcher :shared_group_or_including?, <<~PATTERN
          (block {
            (send #rspec? #SharedGroups.all ...)
            (send nil? #Includes.all ...)
          } ...)
        PATTERN

        # @!method includes_shared_code?(node)
        def_node_search :includes_shared_code?, <<~PATTERN
          (send nil? #Includes.all ...)
        PATTERN

        # @!method includes_call?(node)
        def_node_matcher :includes_call?, <<~PATTERN
          (send nil? #Includes.all ...)
        PATTERN

        # A `let!` connected to shared examples or contexts may be referenced
        # from the shared code, which frequently lives in another file. The
        # project-wide index resolves references across files, so consult it
        # for these `let!` calls rather than reporting a false positive.
        def referenced_via_shared_code?(node, method_name)
          return false unless project_index
          return false unless shared_code_connected?(node)

          project_index_reference_names.include?(method_name.to_s)
        end

        # Whether the node could be referenced from shared code: it lives in
        # a shared group, in a group that includes shared examples/contexts,
        # or in a descendant of such a group (descendants inherit the `let!`
        # via RSpec's `let` inheritance).
        def shared_code_connected?(node)
          return true if shared_group_or_including?(node)
          return true if includes_shared_code?(node)

          # An ancestor's include only connects `node` if the include lives
          # in the ancestor's own scope. An include nested inside a sibling
          # descendant (e.g. another context) cannot reach `node`'s `let!`.
          node.each_ancestor(:block).any? do |ancestor|
            shared_group_or_including?(ancestor) ||
              own_scope_includes?(ancestor)
          end
        end

        def own_scope_includes?(node)
          node.each_child_node.any? do |child|
            include_call_node?(child) ||
              (!rspec_scope?(child) && own_scope_includes?(child))
          end
        end

        # Handles block-form inclusions (e.g. `include_context 'x' do ... end`),
        # whose send node `rspec_scope?` would otherwise treat as a boundary.
        def include_call_node?(node)
          includes_call?(node) ||
            (node.block_type? && includes_call?(node.send_node))
        end

        # An ordinary Ruby block (e.g. `variants.each { include_context ... }`)
        # does not open a new RSpec scope, so an `include` nested inside it
        # still runs in the enclosing example group's scope. Only stop
        # recursing at nodes that establish their own RSpec scope, since an
        # `include` inside one of those cannot affect the outer scope.
        def rspec_scope?(node)
          return false unless node.block_type?

          example_or_shared_group_or_including?(node) || example?(node) ||
            hook?(node)
        end

        def project_index_reference_names
          index, names = self.class.cached_reference_names
          return names if index.equal?(project_index)

          compute_project_index_reference_names.tap do |computed|
            self.class.cached_reference_names = [project_index, computed]
          end
        end

        def compute_project_index_reference_names
          project_index.method_references.to_set do |reference|
            reference.name.delete_suffix('()')
          end
        end
      end
    end
  end
end
