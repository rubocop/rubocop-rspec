# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::Example, :config do
  include RuboCop::AST::Sexp

  let(:cop_class) do
    RuboCop::Cop::RSpec::Base
  end

  # Trigger setting of the `Language` in the case when this spec
  # runs before cops' specs that set it.
  before { cop.on_new_investigation }

  def example(source)
    described_class.new(parse_source(source).ast)
  end

  it 'extracts doc string' do
    expect(example("it('does x') { foo }").doc_string)
      .to eq(s(:str, 'does x'))
  end

  it 'extracts doc string for unimplemented examples' do
    expect(example("it('does x')").doc_string)
      .to eq(s(:str, 'does x'))
  end

  it 'extracts interpolated doc string' do
    expect(example('it("does #{x}")').doc_string)
      .to eq(s(:dstr, s(:str, 'does '), s(:begin, s(:send, nil, :x))))
  end

  it 'extracts symbol doc string' do
    expect(example('it(:works_fine)').doc_string)
      .to eq(s(:sym, :works_fine))
  end

  it 'extracts method doc string' do
    expect(example('it(description)').doc_string)
      .to eq(s(:send, nil, :description))
  end

  it 'returns nil for examples without doc strings' do
    expect(example('it { foo }').doc_string).to be_nil
  end

  it 'extracts keywords' do
    expect(example("it('foo', :bar, baz: :qux) { a }").metadata)
      .to eq([s(:sym, :bar), s(:hash, s(:pair, s(:sym, :baz), s(:sym, :qux)))])
  end

  it 'extracts implementation' do
    expect(example('it("foo") { bar; baz }').implementation)
      .to eq(s(:begin, s(:send, nil, :bar), s(:send, nil, :baz)))
  end

  it 'returns node' do
    node = s(:sym, :node)
    expect(described_class.new(node).to_node).to be(node)
  end

  describe 'value object semantics' do
    # rubocop:disable RSpec/IdenticalEqualityAssertion
    it 'compares by value' do
      aggregate_failures 'equality semantics' do
        expect(example('it("foo")')).to eq(example('it("foo")'))
        expect(example('it("foo")')).not_to eq(example('it("bar")'))
      end
    end
    # rubocop:enable RSpec/IdenticalEqualityAssertion

    it 'can be used as a key in a hash' do
      hash = {}

      hash[example('it("foo")')] = 123

      expect(hash[example('it("foo")')]).to be(123)
    end

    it 'computes #hash based on class and node' do
      node = s(:node)

      expect(described_class.new(node).hash)
        .to eql([described_class, node].hash)
    end
  end
end
