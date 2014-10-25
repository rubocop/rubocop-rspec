# encoding: utf-8

describe RuboCop::Cop::RSpec::MultipleDescribes do
  subject(:cop) { described_class.new }

  it 'finds multiple top level describes with class and method' do
    inspect_source(cop, ["describe MyClass, '.do_something' do; end",
                         "describe MyClass, '.do_something_else' do; end"])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Do not use multiple top level describes - ' \
                                'try to nest them.'])
  end

  it 'finds multiple top level describes only with class' do
    inspect_source(cop, ['describe MyClass do; end',
                         'describe MyOtherClass do; end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages).to eq(['Do not use multiple top level describes - ' \
                                'try to nest them.'])
  end

  it 'skips single top level describe' do
    inspect_source(cop, ["require 'spec_helper'",
                         '',
                         'describe MyClass do; end'])
    expect(cop.offenses).to be_empty
  end
end
