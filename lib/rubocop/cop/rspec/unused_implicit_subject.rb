# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for usage of explicit subject that could be implicit.
      #
      # This Cop is not safe as it might be confused by what is the subject.
      #
      #   # bad
      #   subject(:foo) { :bar }
      #   it { expect(foo).to eq :bar }
      #   it { foo.should eq :bar }
      #
      #   # good
      #   subject(:foo) { :bar }
      #   it { is_expected.to eq :bar }
      #   it { should eq :bar }
      #
      #   # also good
      #   it { expect { foo }.to raise_error }
      #   it { expect(foo.to_s).to eq 'bar' }
      #
      class UnusedImplicitSubject < Base
        extend AutoCorrector

        MSG = 'Use implicit subject.'
        RESTRICT_ON_SEND = %i[expect should subject subject!].freeze

        def_node_matcher :subject_definition,
                         '(send #rspec? {:subject :subject!} (sym $_name))'
        def_node_matcher :subject_should?,
                         '(send (send nil? %subject) :should ...)'
        def_node_matcher :expect_subject?,
                         '(send nil? :expect (send nil? %subject))'

        def on_send(node)
          send(node.method_name, node)
        end

        private

        def subject(node)
          @cur_subject = subject_definition(node)
        end
        alias subject! subject

        def should(node)
          return unless subject_should?(node, subject: @cur_subject)

          range = node.receiver.loc.expression.join(node.loc.selector)
          add_offense(range) { |c| c.replace(range, 'should') }
        end

        def expect(node)
          return unless expect_subject?(node, subject: @cur_subject)

          add_offense(node) { |c| c.replace(node, 'is_expected') }
        end
      end
    end
  end
end
