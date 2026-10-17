# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::ExampleGroup, :config do
  include RuboCop::AST::Sexp

  subject(:group) { described_class.new(parse_source(source).ast) }

  let(:cop_class) { RuboCop::Cop::RSpec::Base }

  let(:source) do
    <<~RUBY
      RSpec.describe Foo do
        it 'does x' do
          x
        end

        it 'does y' do
          y
        end

        context 'nested' do
          it 'does z' do
            z
          end
        end
      end
    RUBY
  end

  let(:example_nodes) do
    [
      s(:block,
        s(:send, nil, :it,
          s(:str, 'does x')),
        s(:args), s(:send, nil, :x)),
      s(:block,
        s(:send, nil, :it,
          s(:str, 'does y')),
        s(:args), s(:send, nil, :y))
    ].map { |node| RuboCop::RSpec::Example.new(node) }
  end

  # Trigger setting of the `Language` in the case when this spec
  # runs before cops' specs that set it.
  before { cop.on_new_investigation }

  it 'exposes examples in scope' do
    expect(group.examples).to eql(example_nodes)
  end

  context 'with declarations nested in an example, hook or memoized helper' do
    let(:source) do
      <<~RUBY
        RSpec.describe Foo do
          let(:a) do
            subject(:nested) { 1 }
          end
          subject(:b) do
            before { nested }
          end
          before do
            let(:nested) { 1 }
            it('nested') { x }
          end
          it 'does x' do
            x
          end
        end
      RUBY
    end

    it 'exposes only the lets the group declares' do
      expect(group.lets.map(&:first_line)).to eq([2])
    end

    it 'exposes only the subjects the group declares' do
      expect(group.subjects.map(&:first_line)).to eq([5])
    end

    it 'exposes only the hooks the group declares' do
      expect(group.hooks.map { |hook| hook.to_node.first_line }).to eq([8])
    end

    it 'exposes only the examples the group declares' do
      expect(group.examples.map { |example| example.to_node.first_line })
        .to eq([12])
    end
  end

  context 'with declarations in a block called on a constant' do
    let(:source) do
      <<~RUBY
        RSpec.describe Foo do
          Definition.define do
            let(:a) { 1 }
            subject(:b) { 2 }
            before { c }
            it('d') { d }
          end
          KINDS.each do |kind|
            let(kind) { 1 }
            subject(kind) { 2 }
            before { c }
            it(kind) { d }
          end
        end
      RUBY
    end

    it 'exposes lets from the iterator, not the DSL block' do
      expect(group.lets.map(&:first_line)).to eq([9])
    end

    it 'exposes subjects from the iterator, not the DSL block' do
      expect(group.subjects.map(&:first_line)).to eq([10])
    end

    it 'exposes hooks from the iterator, not the DSL block' do
      expect(group.hooks.map { |hook| hook.to_node.first_line }).to eq([11])
    end

    it 'exposes examples from the iterator, not the DSL block' do
      expect(group.examples.map { |example| example.to_node.first_line })
        .to eq([12])
    end
  end
end
