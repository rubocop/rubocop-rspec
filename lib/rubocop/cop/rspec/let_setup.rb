# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks unreferenced `let!` calls being used for test setup.
      #
      # A `let!` that is defined in a `shared_context`/`shared_examples` block,
      # or in an example group that includes shared examples, may be referenced
      # from the shared code rather than from the example group itself. Whether
      # such a reference is present cannot be determined from a single file,
      # because the shared code is often defined elsewhere. When
      # `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed,
      # the cop consults the project-wide index for these `let!` calls and does
      # not flag one whose name is referenced anywhere in the project. Without
      # the index it falls back to the file-local check, which may report such a
      # `let!` as unused.
      #
      # @example
      #   # bad
      #   let!(:my_widget) { create(:widget) }
      #
      #   it 'counts widgets' do
      #     expect(Widget.count).to eq(1)
      #   end
      #
      #   # good
      #   it 'counts widgets' do
      #     create(:widget)
      #     expect(Widget.count).to eq(1)
      #   end
      #
      #   # good
      #   before { create(:widget) }
      #
      #   it 'counts widgets' do
      #     expect(Widget.count).to eq(1)
      #   end
      #
      #   # good
      #   describe 'a widget' do
      #     let!(:my_widget) { create(:widget) }
      #     context 'when visiting its page' do
      #       let!(:my_widget) { create(:widget, name: 'Special') }
      #       it 'counts widgets' do
      #         expect(Widget.count).to eq(1)
      #       end
      #     end
      #   end
      #
      class LetSetup < Base
        include SharedCodeReference

        MSG = 'Do not use `let!` to setup objects not referenced in tests.'

        # @!method example_or_shared_group_or_including?(node)
        def_node_matcher :example_or_shared_group_or_including?, <<~PATTERN
          (block {
            (send #rspec? {#SharedGroups.all #ExampleGroups.all} ...)
            (send nil? #Includes.all ...)
          } ...)
        PATTERN

        # @!method let_bang(node)
        def_node_matcher :let_bang, <<~PATTERN
          {
            (block $(send nil? :let! {(sym $_) (str $_)}) ...)
            $(send nil? :let! {(sym $_) (str $_)} block_pass)
          }
        PATTERN

        # @!method method_called?(node)
        def_node_search :method_called?, '(send nil? %)'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          return unless example_or_shared_group_or_including?(node)

          unused_let_bang(node) do |let|
            add_offense(let)
          end
        end

        private

        def unused_let_bang(node)
          child_let_bang(node) do |method_send, method_name|
            next if overrides_outer_let_bang?(node, method_name)
            next if method_called?(node, method_name.to_sym)
            next if referenced_via_shared_code?(node, method_name)

            yield(method_send)
          end
        end

        def child_let_bang(node, &block)
          RuboCop::RSpec::ExampleGroup.new(node).lets.each do |let|
            let_bang(let, &block)
          end
        end

        def overrides_outer_let_bang?(node, method_name)
          node.each_ancestor(:block).any? do |ancestor|
            next unless example_or_shared_group_or_including?(ancestor)

            outer_let_bang?(ancestor, method_name)
          end
        end

        def outer_let_bang?(ancestor_node, method_name)
          RuboCop::RSpec::ExampleGroup.new(ancestor_node).lets.any? do |let|
            let_bang(let) do |_send, name|
              name == method_name
            end
          end
        end
      end
    end
  end
end
