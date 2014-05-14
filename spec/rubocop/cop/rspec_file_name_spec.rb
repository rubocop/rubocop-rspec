# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::RSpecFileName do
  subject(:cop) { described_class.new }

  it 'checks the path' do
    inspect_source(cop,
                   ["describe MyClass, '#foo' do; end"],
                   'wrong_path/foo_spec.rb')
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Unit spec should have a path matching ' \
                                '`my_class/foo_spec.rb`'])
  end

  it 'checks class spec paths' do
    inspect_source(cop,
                   ['describe MyClass do; end'],
                   'wrong_class_spec.rb')
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Class unit spec should have a path ending ' \
                                'with `my_class_spec.rb`'])
  end

  it 'checks class specs' do
    inspect_source(cop,
                   ['describe Some::Class do; end'],
                   'some/class_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'handles CamelCaps class names' do
    inspect_source(cop,
                   ['describe MyClass do; end'],
                   'my_class_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'handles ACRONYMClassNames' do
    inspect_source(cop,
                   ['describe ABCOne::Two do; end'],
                   'abc_one/two_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'handles ALLCAPS class names' do
    inspect_source(cop,
                   ['describe ALLCAPS do; end'],
                   'allcaps_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'checks instance methods' do
    inspect_source(cop,
                   ["describe Some::Class, '#inst' do; end"],
                   'some/class/inst_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'checks class methods' do
    inspect_source(cop,
                   ["describe Some::Class, '.inst' do; end"],
                   'some/class/class_methods/inst_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'ignores non-alphanumeric characters' do
    inspect_source(cop,
                   ["describe Some::Class, '#pred?' do; end"],
                   'some/class/pred_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'allows flexibility with predicates' do
    inspect_source(cop,
                   ["describe Some::Class, '#thing?' do; end"],
                   'some/class/thing_predicate_spec.rb')
    expect(cop.offenses).to be_empty
  end

  it 'allows flexibility with operators' do
    inspect_source(cop,
                   ["describe MyClass, '#<=>' do; end"],
                   'my_class/spaceship_operator_spec.rb')
    expect(cop.offenses).to be_empty
  end
end
