describe RuboCop::Cop::RSpec::FilePath, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'invalid spec path' do |source, expected:, actual:|
    context "when `#{source}` is defined in #{actual}" do
      before do
        inspect_source(cop, source, actual)
      end

      it 'flags an offense' do
        expect(cop.offenses.size).to eq(1)
      end

      it 'registers the offense on line 1' do
        expect(cop.offenses.map(&:line)).to eq([1])
      end

      it 'adds a message saying what the path should end with' do
        expect(cop.messages).to eql(["Spec path should end with `#{expected}`"])
      end
    end
  end

  include_examples 'invalid spec path',
                   "describe MyClass, 'foo' do; end",
                   expected: 'my_class*foo*_spec.rb',
                   actual:   'wrong_path_foo_spec.rb'

  include_examples 'invalid spec path',
                   "describe MyClass, '#foo' do; end",
                   expected: 'my_class*foo*_spec.rb',
                   actual: 'wrong_class_foo_spec.rb'

  include_examples 'invalid spec path',
                   "describe MyClass, '#foo' do; end",
                   expected: 'my_class*foo*_spec.rb',
                   actual: 'my_class/foo_spec.rb.rb'

  include_examples 'invalid spec path',
                   "describe MyClass, '#foo' do; end",
                   expected: 'my_class*foo*_spec.rb',
                   actual: 'my_class/foo_specorb'

  include_examples 'invalid spec path',
                   "describe MyClass, '#foo', blah: :blah do; end",
                   expected: 'my_class*foo*_spec.rb',
                   actual: 'wrong_class_foo_spec.rb'

  include_examples 'invalid spec path',
                   'describe MyClass do; end',
                   expected: 'my_class*_spec.rb',
                   actual: 'wrong_class_spec.rb'

  include_examples 'invalid spec path',
                   'describe MyClass, :foo do; end',
                   expected: 'my_class*_spec.rb',
                   actual: 'wrong_class_spec.rb'

  it 'skips specs that do not describe a class / method' do
    inspect_source(
      cop,
      "describe 'Test something' do; end",
      'some/class/spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'skips specs that do have multiple top level describes' do
    inspect_source(
      cop,
      [
        "describe MyClass, 'do_this' do; end",
        "describe MyClass, 'do_that' do; end"
      ],
      'some/class/spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'checks class specs' do
    inspect_source(
      cop,
      'describe Some::Class do; end',
      'some/class_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'handles CamelCaps class names' do
    inspect_source(
      cop,
      'describe MyClass do; end',
      'my_class_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'handles ACRONYMClassNames' do
    inspect_source(
      cop,
      'describe ABCOne::Two do; end',
      'abc_one/two_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'handles ALLCAPS class names' do
    inspect_source(
      cop,
      'describe ALLCAPS do; end',
      'allcaps_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'handles alphanumeric class names' do
    inspect_source(
      cop,
      'describe IPv4AndIPv6 do; end',
      'i_pv4_and_i_pv6_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'checks instance methods' do
    inspect_source(
      cop,
      "describe Some::Class, '#inst' do; end",
      'some/class/inst_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'checks class methods' do
    inspect_source(
      cop,
      "describe Some::Class, '.inst' do; end",
      'some/class/inst_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows flat hierarchies for instance methods' do
    inspect_source(
      cop,
      "describe Some::Class, '#inst' do; end",
      'some/class_inst_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows flat hierarchies for class methods' do
    inspect_source(
      cop,
      "describe Some::Class, '.inst' do; end",
      'some/class_inst_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows subdirs for instance methods' do
    inspect_source(
      cop,
      "describe Some::Class, '#inst' do; end",
      'some/class/instance_methods/inst_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows subdirs for class methods' do
    inspect_source(
      cop,
      "describe Some::Class, '.inst' do; end",
      'some/class/class_methods/inst_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'ignores non-alphanumeric characters' do
    inspect_source(
      cop,
      "describe Some::Class, '#pred?' do; end",
      'some/class/pred_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows bang method' do
    inspect_source(
      cop,
      "describe Some::Class, '#bang!' do; end",
      'some/class/bang_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows flexibility with predicates' do
    inspect_source(
      cop,
      "describe Some::Class, '#thing?' do; end",
      'some/class/thing_predicate_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  it 'allows flexibility with operators' do
    inspect_source(
      cop,
      "describe MyLittleClass, '#<=>' do; end",
      'my_little_class/spaceship_operator_spec.rb'
    )
    expect(cop.offenses).to be_empty
  end

  context 'when configured' do
    let(:cop_config) { { 'CustomTransform' => { 'FooFoo' => 'foofoo' } } }

    it 'respects custom module name transformation' do
      inspect_source(
        cop,
        "describe FooFoo::Some::Class, '#bar' do; end",
        'foofoo/some/class/bar_spec.rb'
      )
      expect(cop.offenses).to be_empty
    end

    it 'ignores routing specs' do
      inspect_source(
        cop,
        'describe MyController, "#foo", type: :routing do; end',
        'foofoo/some/class/bar_spec.rb'
      )
      expect(cop.offenses).to be_empty
    end
  end
end
