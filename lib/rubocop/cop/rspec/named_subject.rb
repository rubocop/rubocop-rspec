# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for explicitly referenced test subjects.
      #
      # RSpec lets you declare an "implicit subject" using `subject { ... }`
      # which allows for tests like `it { should be_valid }`. If you need to
      # reference your test subject you should explicitly name it using
      # `subject(:your_subject_name) { ... }`. Your test subjects should be
      # the most important object in your tests so they deserve a descriptive
      # name.
      #
      # This cop can be configured in your configuration using the
      # `IgnoreSharedExamples` which will not report offenses for implicit
      # subjects in shared example groups.
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
        MSG = 'Name your test subject if you need '\
              'to reference it explicitly.'

        def_node_matcher :rspec_block?, <<-PATTERN
          {
            #{Examples::ALL.block_pattern}
            #{Hooks::ALL.block_pattern}
          }
        PATTERN

        def_node_matcher :shared_example?, <<-PATTERN
          #{SharedGroups::EXAMPLES.block_pattern}
        PATTERN

        def_node_search :subject_usage, '$(send nil? :subject)'

        def on_block(node)
          add_offense(node) if node.parent.nil? && use_implicit_subject?(node)

          RuboCop::RSpec::ExampleGroup.new(node).subjects.each do |subject|
            next if named_subject?(subject)
            add_offense(subject)
          end

          return if !rspec_block?(node) || ignored_shared_example?(node)

          subject_usage(node) do |subject_node|
            add_offense(subject_node, location: :selector)
          end
        end

        def ignored_shared_example?(node)
          cop_config['IgnoreSharedExamples'] &&
            node.each_ancestor(:block).any?(&method(:shared_example?))
        end

        def autocorrect(node)
          if node.parent.nil? && use_implicit_subject?(node)
            correct_by_adding_explicit_subject(node)
          elsif subject_definition?(node)
            correct_subject_definition(node)
          else
            correct_subject_usage(node)
          end
        end

        private

        def named_subject?(node)
          node.send_node.arguments?
        end

        def subject_definition?(node)
          node.type == :block
        end

        def correct_subject_definition(node)
          lambda do |corrector|
            name = subject_name(node.ancestors.last)
            next unless name

            repacement = "subject(:#{name})"
            corrector.replace(node.send_node.loc.selector, repacement)
          end
        end

        def correct_by_adding_explicit_subject(node)
          lambda do |corrector|
            name = subject_name(node)
            next unless name

            top_block = node.children[2]
            next unless top_block

            repacement = "\n  subject(:#{name}) { described_class.new }\n"
            corrector.insert_after(
              top_block.loc.expression,
              repacement
            )
          end
        end

        def correct_subject_usage(node)
          lambda do |corrector|
            name = find_subject_usage_name(node)
            next unless name

            corrector.replace(node.loc.selector, name)
          end
        end

        def find_subject_usage_name(node)
          node.each_ancestor do |ancestor|
            return subject_name(ancestor) if ancestor.parent.nil?

            RuboCop::RSpec::ExampleGroup.new(ancestor).subjects.each do |subject|
              if named_subject?(subject)
                subject_name = subject.send_node.arguments.first.source
                usage_name = subject_name.dup.tap {|s| s[0] = '' } # remove first ':' character
                return usage_name
              end
            end
          end

          nil
        end

        def subject_name(node)
          top_call = node.node_parts.first
          top_call_first_arg = top_call.arguments.first
          return if top_call_first_arg.nil?

          klass_name_with_namespace = top_call_first_arg.source
          klass_name = klass_name_with_namespace.split('::').last
          underscore(klass_name).downcase
        end

        def underscore(camel_cased_word)
          return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
          word = camel_cased_word.to_s.gsub("::", "/")
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.tr!("-", "_")
          word.downcase!
          word
        end

        def use_implicit_subject?(node)
          return false if RuboCop::RSpec::ExampleGroup.new(node).subjects.any?
          return true if subject_usage(node)

          node.children.any? { |child| use_implicit_subject?(child) }
        end
      end
    end
  end
end
