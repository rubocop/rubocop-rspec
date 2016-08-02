# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Give `subject` a descriptive name if you reference it directly
      #
      # @example
      #   # bad
      #   RSpec.describe User do
      #     subject { described_class.new }
      #
      #     it 'is valid' do
      #       expect(subject.valid?).to be(true)
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe Foo do
      #     subject(:user) { described_class.new }
      #
      #     it 'is valid' do
      #       expect(user.valid?).to be(true)
      #     end
      #   end
      #
      #   # also good
      #   RSpec.describe Foo do
      #     subject(:user) { described_class.new }
      #
      #     it { should be_valid }
      #   end
      class NamedSubject < Cop
        MSG = 'Name your test subject if '\
              'you need to reference it explicitly.'.freeze

        def_node_matcher :rspec_block?, <<-PATTERN
          (block
            (send nil {:it :specify :before :after :around} ...)
            ...)
        PATTERN

        def_node_matcher :unnamed_subject, '$(send nil :subject)'

        def on_block(node)
          return unless rspec_block?(node)

          subject_usage(node) do |subject_node|
            add_offense(subject_node, :selector)
          end
        end

        private

        def subject_usage(node, &block)
          return unless node.instance_of?(Node)

          unnamed_subject(node, &block)

          node.children.each do |child|
            subject_usage(child, &block)
          end
        end
      end
    end
  end
end
