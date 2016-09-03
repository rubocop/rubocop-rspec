describe RuboCop::Cop::RSpec::ExampleWording, :config do
  subject(:cop) { described_class.new(config) }

  context 'with configuration' do
    let(:cop_config) do
      {
        'CustomTransform' => { 'have' => 'has', 'not' => 'does not' },
        'IgnoredWords' => %w(only really)
      }
    end

    it 'ignores non-example blocks' do
      expect_no_violations('foo "should do something" do; end')
    end

    it 'finds description with `should` at the beginning' do
      expect_violation(<<-RUBY)
        it 'should do something' do
            ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY
    end

    it 'finds description with `Should` at the beginning' do
      expect_violation(<<-RUBY)
        it 'Should do something' do
            ^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY
    end

    it 'finds description with `shouldn\'t` at the beginning' do
      expect_violation(<<-RUBY)
        it "shouldn't do something" do
            ^^^^^^^^^^^^^^^^^^^^^^ Do not use should when describing your tests.
        end
      RUBY
    end

    it 'skips descriptions without `should` at the beginning' do
      expect_no_violations(<<-RUBY)
        it 'finds no should here' do
        end
      RUBY
    end

    include_examples 'autocorrect',
                     'it "should only have trait" do end',
                     'it "only has trait" do end'
  end

  context 'when configuration is empty' do
    include_examples 'autocorrect',
                     'it "should have trait" do end',
                     'it "haves trait" do end'

    include_examples 'autocorrect',
                     'it "should only fail" do end',
                     'it "onlies fail" do end'
  end
end
