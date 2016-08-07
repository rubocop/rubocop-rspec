# frozen_string_literal: true

describe RuboCop::Cop::RSpec::NestedGroups, :config do
  subject(:cop) { described_class.new(config) }

  include_examples 'an rspec only cop'

  it 'flags nested contexts' do
    expect_violation(<<-RUBY)
      describe MyClass do
        context 'when foo' do
          context 'when bar' do
          ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
            context 'when baz' do
            ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
            end
          end
        end

        context 'when qux' do
          context 'when norf' do
          ^^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
          end
        end
      end
    RUBY
  end

  it 'ignores non-spec context methods' do
    expect_no_violations(<<-RUBY)
      class MyThingy
        context 'this is not rspec' do
          context 'but it uses contexts' do
          end
        end
      end
    RUBY
  end

  context 'when MaxNesting is configured as 2' do
    let(:cop_config) { { 'MaxNesting' => '3' } }

    it 'only flags third level of nesting' do
      expect_violation(<<-RUBY)
        describe MyClass do
          context 'when foo' do
            context 'when bar' do
              context 'when baz' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
              end
            end
          end
        end
      RUBY
    end
  end
end
