describe RuboCop::Cop::RSpec::BeforeAfterAll, :config do
  subject(:cop) { described_class.new(config) }

  context 'when offenses detected' do
    let(:code) do
      [
        'describe MyClass do',
        '  before(:all) { do_something}',
        '  after(:all) { do_something_else }',
        'end'
      ]
    end

    let(:expected_error) do
      'Beware of using `before/after(:all)` as it may cause state to leak '\
        'between tests. If you are using rspec-rails, and '\
        '`use_transactional_fixtures` is enabled, then records created in '\
        '`before(:all)` are not rolled back.'
    end

    it 'reports 2 offenses' do
      inspect_source(cop, code, 'foo_spec.rb')
      expect(cop.offenses.size).to eq(2)
    end

    it 'reports the lines for these offenses' do
      inspect_source(cop, code, 'foo_spec.rb')
      expect(cop.offenses.map(&:line).sort).to eq([2, 3])
    end

    it 'describes the offenses' do
      inspect_source(cop, code, 'foo_spec.rb')
      expect(cop.messages).to eq([expected_error, expected_error])
    end
  end

  it 'complains for :context' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before(:context) { do_something }',
        '  after(:context) { do_something_else }',
        'end'
      ],
      'foo_spec.rb'
    )
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not complain for before/after :each' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before(:each) { do_something }',
        '  after(:each) { do_something_else }',
        'end'
      ],
      'foo_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'does not complain for before/after :example' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before(:example) { do_something }',
        '  after(:example) { do_something_else }',
        'end'
      ],
      'foo_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'does not complain for before/after' do
    inspect_source(
      cop,
      [
        'describe MyClass do',
        '  before { do_something }',
        '  after { do_something_else }',
        'end'
      ],
      'foo_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end
end
