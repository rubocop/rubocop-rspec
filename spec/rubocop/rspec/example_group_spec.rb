# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::ExampleGroup, :config do
  include RuboCop::AST::Sexp

  subject(:group) do
    described_class.new(parse_source(source).ast)
  end

  let(:cop_class) do
    RuboCop::Cop::RSpec::Base
  end

  let(:source) do
    <<-RUBY
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
end
