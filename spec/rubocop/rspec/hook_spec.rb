# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::Hook, :config do
  include RuboCop::AST::Sexp

  let(:cop_class) { RuboCop::Cop::RSpec::Base }

  # Trigger setting of the `Language` in the case when this spec
  # runs before cops' specs that set it.
  before { cop.on_new_investigation }

  def hook(source)
    described_class.new(parse_source(source).ast)
  end

  it 'extracts name' do
    expect(hook('around(:each) { }').name).to be(:around)
  end

  describe '#knowable_scope?' do
    it 'does not break if a hook is not given a symbol literal' do
      expect(hook('before(scope) { example_setup }').knowable_scope?)
        .to be(false)
    end

    it 'knows the scope of a hook with a symbol literal' do
      expect(hook('before(:example) { example_setup }').knowable_scope?)
        .to be(true)
    end

    it 'knows the scope of a hook with no argument' do
      expect(hook('before { example_setup }').knowable_scope?)
        .to be(true)
    end

    it 'knows the scope of a hook with hash metadata' do
      expect(hook('before(special: true) { example_setup }').knowable_scope?)
        .to be(true)
    end
  end

  describe '#scope' do
    it 'ignores other arguments to hooks' do
      expect(hook('before(:each, :metadata) { example_setup }').scope)
        .to be(:each)
    end

    it 'ignores invalid hooks' do
      expect(hook('before(:invalid) { example_setup }').scope)
        .to be_nil
    end

    it 'classifies :each as an example hook' do
      expect(hook('before(:each) { }').example?).to be(true)
    end

    it 'defaults to example hook with hash metadata' do
      expect(hook('before(special: true) { }').example?).to be(true)
    end

    shared_examples 'standardizes scope' do |source, scope|
      it "interprets #{source} as having scope #{scope}" do
        expect(hook(source).scope).to equal(scope)
      end
    end

    it_behaves_like 'standardizes scope', 'before(:each) { }',    :each
    it_behaves_like 'standardizes scope', 'around(:example) { }', :each
    it_behaves_like 'standardizes scope', 'after { }',            :each

    it_behaves_like 'standardizes scope', 'before(:all) { }',     :context
    it_behaves_like 'standardizes scope', 'around(:context) { }', :context

    it_behaves_like 'standardizes scope', 'after(:suite) { }', :suite
  end

  describe '#metadata' do
    def metadata(source)
      hook(source).metadata.to_s
    end

    if RUBY_VERSION >= '3.4'
      let(:expected_focus) { 's(:sym, :focus) => true' }
      let(:expected_invalid) { '{s(:sym, :invalid) => true}' }
      let(:expected_special) { 's(:sym, :special) => true' }
      let(:expected_symbol) { 's(:sym, :symbol) => true' }
    else
      let(:expected_focus) { 's(:sym, :focus)=>true' }
      let(:expected_invalid) { '{s(:sym, :invalid)=>true}' }
      let(:expected_special) { 's(:sym, :special)=>true' }
      let(:expected_symbol) { 's(:sym, :symbol)=>true' }
    end

    it 'extracts symbol metadata' do
      expect(metadata('before(:example, :special) { foo }'))
        .to eq("{#{expected_special}}")
    end

    it 'extracts hash metadata' do
      expect(metadata('before(:example, special: true) { foo }'))
        .to eq("{#{expected_special}}")
    end

    it 'combines symbol and hash metadata' do
      expect(metadata('before(:example, :symbol, special: true) { foo }'))
        .to eq("{#{expected_symbol}, #{expected_special}}")
    end

    it 'extracts hash metadata with no scope given' do
      expect(metadata('before(special: true) { foo }'))
        .to eq("{#{expected_special}}")
    end

    it 'withstands no arguments' do
      expect(metadata('before { foo }')).to be_empty
    end

    it 'returns the symbol even when an invalid symbol scope is provided' do
      expect(metadata('before(:invalid) { foo }')).to eq(expected_invalid)
    end

    it 'extracts multiple symbol metadata' do
      expect(metadata('before(:example, :special, :focus) { foo }'))
        .to eq("{#{expected_special}, #{expected_focus}}")
    end

    it 'extracts multiple hash metadata' do
      expect(metadata('before(:example, special: true, focus: true) { foo }'))
        .to eq("{#{expected_special}, #{expected_focus}}")
    end

    it 'combines multiple symbol and hash metadata' do
      expect(
        metadata(
          'before(:example, :symbol, special: true, focus: true) { foo }'
        )
      ).to eq("{#{expected_symbol}, #{expected_special}, #{expected_focus}}")
    end
  end
end
