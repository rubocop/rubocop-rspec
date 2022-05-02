# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FilePath do
  it 'registers an offense for a bad path' do
    expect_offense(<<-RUBY, 'wrong_path_foo_spec.rb')
      describe MyClass, 'foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a bad path for all kinds of example groups' do
    expect_offense(<<-RUBY, 'wrong_path_foo_spec.rb')
      example_group MyClass, 'foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a wrong class but a correct method' do
    expect_offense(<<-RUBY, 'wrong_class_foo_spec.rb')
      describe MyClass, '#foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a repeated .rb' do
    expect_offense(<<-RUBY, 'my_class/foo_spec.rb.rb')
      describe MyClass, '#foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a file missing a .rb' do
    expect_offense(<<-RUBY, 'my_class/foo_specorb')
      describe MyClass, '#foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a wrong class and highlights metadata' do
    expect_offense(<<-RUBY, 'wrong_class_foo_spec.rb')
      describe MyClass, '#foo', blah: :blah do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a wrong class name' do
    expect_offense(<<-RUBY, 'wrong_class_spec.rb')
      describe MyClass do; end
      ^^^^^^^^^^^^^^^^ Spec path should end with `my_class*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a wrong class name with a symbol argument' do
    expect_offense(<<-RUBY, 'wrong_class_spec.rb')
      describe MyClass, :foo do; end
      ^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a file missing _spec' do
    expect_offense(<<-RUBY, 'spec/models/user.rb')
      describe User do; end
      ^^^^^^^^^^^^^ Spec path should end with `user*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a feature file missing _spec' do
    expect_offense(<<-RUBY, 'spec/features/my_feature.rb')
      feature "my feature" do; end
      ^^^^^^^^^^^^^^^^^^^^ Spec path should end with `*_spec.rb`.
    RUBY
  end

  it 'registers an offense for a file without the .rb extension' do
    expect_offense(<<-RUBY, 'spec/models/user_specxrb')
      describe User do; end
      ^^^^^^^^^^^^^ Spec path should end with `user*_spec.rb`.
    RUBY
  end

  it 'does not register an offense for shared examples' do
    expect_no_offenses(<<-RUBY, 'spec/models/user.rb')
      shared_examples_for 'foo' do; end
    RUBY
  end

  it 'does not register an offence for example groups '\
     'do not describe a class / method' do
    expect_no_offenses(<<-RUBY, 'some/class/spec.rb')
      describe 'Test something' do; end
    RUBY
  end

  it 'does not register an offense for multiple top level describes' do
    expect_no_offenses(<<-RUBY, 'some/class/spec.rb')
      describe MyClass, 'do_this' do; end
      describe MyClass, 'do_that' do; end
    RUBY
  end

  it 'does not register an offense for class specs' do
    expect_no_offenses(<<-RUBY, 'some/class_spec.rb')
      describe Some::Class do; end
    RUBY
  end

  it 'does not register an offense for different parent directories' do
    expect_no_offenses(<<-RUBY, 'parent_dir/some/class_spec.rb')
      describe Some::Class do; end
    RUBY
  end

  it 'does not register an offense for CamelCaps class names' do
    expect_no_offenses(<<-RUBY, 'my_class_spec.rb')
      describe MyClass do; end
    RUBY
  end

  it 'does not register an offense for ACRONYMClassNames' do
    expect_no_offenses(<<-RUBY, 'abc_one/two_spec.rb')
      describe ABCOne::Two do; end
    RUBY
  end

  it 'does not register an offense for ALLCAPS class names' do
    expect_no_offenses(<<-RUBY, 'allcaps_spec.rb')
      describe ALLCAPS do; end
    RUBY
  end

  it 'does not register an offense for alphanumeric class names' do
    expect_no_offenses(<<-RUBY, 'ipv4_and_ipv6_spec.rb')
      describe IPV4AndIPV6 do; end
    RUBY
  end

  it 'does not register an offense for instance methods' do
    expect_no_offenses(<<-RUBY, 'some/class/inst_spec.rb')
      describe Some::Class, '#inst' do; end
    RUBY
  end

  it 'does not register an offense for class methods' do
    expect_no_offenses(<<-RUBY, 'some/class/inst_spec.rb')
      describe Some::Class, '.inst' do; end
    RUBY
  end

  it 'does not register an offense for flat hierarchies for instance methods' do
    expect_no_offenses(<<-RUBY, 'some/class_inst_spec.rb')
      describe Some::Class, '#inst' do; end
    RUBY
  end

  it 'does not register an offense for flat hierarchies for class methods' do
    expect_no_offenses(<<-RUBY, 'some/class_inst_spec.rb')
      describe Some::Class, '.inst' do; end
    RUBY
  end

  it 'does not register an offense for subdirs for instance methods' do
    filename = 'some/class/instance_methods/inst_spec.rb'
    expect_no_offenses(<<-RUBY, filename)
      describe Some::Class, '#inst' do; end
    RUBY
  end

  it 'does not register an offense for subdirs for class methods' do
    filename = 'some/class/class_methods/inst_spec.rb'
    expect_no_offenses(<<-RUBY, filename)
      describe Some::Class, '.inst' do; end
    RUBY
  end

  it 'does not register an offense for non-alphanumeric characters' do
    expect_no_offenses(<<-RUBY, 'some/class/pred_spec.rb')
      describe Some::Class, '#pred?' do; end
    RUBY
  end

  it 'does not register an offense for bang method' do
    expect_no_offenses(<<-RUBY, 'some/class/bang_spec.rb')
      describe Some::Class, '#bang!' do; end
    RUBY
  end

  it 'does not register an offence for an arbitrary spec suffix' do
    filename = 'some/class/thing_predicate_spec.rb'
    expect_no_offenses(<<-RUBY, filename)
      describe Some::Class, '#thing?' do; end
    RUBY
  end

  it 'does not register an offence for an arbitrary spec name '\
     'for an operator method' do
    filename = 'my_little_class/spaceship_operator_spec.rb'
    expect_no_offenses(<<-RUBY, filename)
      describe MyLittleClass, '#<=>' do; end
    RUBY
  end

  it 'registers an offense for a path containing the class name' do
    expect_offense(<<-RUBY, '/home/foo/spec/models/bar_spec.rb')
      describe Foo do; end
      ^^^^^^^^^^^^ Spec path should end with `foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense for path based on a class name with long module' do
    expect_offense(<<-RUBY, '/home/foo/spec/very/my_class_spec.rb')
      describe Very::Long::Namespace::MyClass do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `very/long/namespace/my_class*_spec.rb`.
    RUBY
  end

  it 'does not register offense for absolute file path' do
    allow(File).to receive(:expand_path).with('my_class_spec.rb').and_return(
      '/home/foo/spec/very/long/namespace/my_class_spec.rb'
    )
    expect_no_offenses(<<-RUBY, 'my_class_spec.rb')
      describe Very::Long::Namespace::MyClass do; end
    RUBY
  end

  # RSpec/FilePath runs on all files - not only **/*_spec.rb
  it 'does not register an offense for files defining an empty class' do
    expect_no_offenses(<<-RUBY)
      class Foo
      end
    RUBY
  end

  context 'when configured with CustomTransform' do
    let(:cop_config) { { 'CustomTransform' => { 'FooFoo' => 'foofoo' } } }

    it 'does not register an offense for custom module name transformation' do
      expect_no_offenses(<<-RUBY, 'foofoo/some/class/bar_spec.rb')
        describe FooFoo::Some::Class, '#bar' do; end
      RUBY
    end

    it 'does not register an offense for routing specs' do
      expect_no_offenses(<<-RUBY, 'foofoo/some/class/bar_spec.rb')
        describe MyController, "#foo", type: :routing do; end
      RUBY
    end
  end

  context 'when ActiveSupport Inflector is defined', order: :defined do
    before { require 'active_support/inflector' }

    it 'registers an offense for a bad path when there is no custom acronym' do
      expect_offense(<<-RUBY, 'pvp_class_foo_spec.rb')
        describe PvPClass, 'foo' do; end
        ^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `pv_p_class*foo*_spec.rb`.
      RUBY
    end

    it 'does not register an offense when class name contains custom acronym' do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.acronym('PvP')
      end

      expect_no_offenses(<<-RUBY, 'pvp_class_foo_spec.rb')
        describe PvPClass, 'foo' do; end
      RUBY
    end
  end

  context 'when configured with IgnoreMethods' do
    let(:cop_config) { { 'IgnoreMethods' => true } }

    it 'does not register an offense for the described method' do
      expect_no_offenses(<<-RUBY, 'my_class_spec.rb')
        describe MyClass, '#look_here_a_method' do; end
      RUBY
    end
  end

  context 'when configured with SpecSuffixOnly' do
    let(:cop_config) { { 'SpecSuffixOnly' => true } }

    it 'does not register an offense for the described class' do
      expect_no_offenses(<<-RUBY, 'whatever_spec.rb')
        describe MyClass do; end
      RUBY
    end

    it 'registers an offense when _spec.rb suffix is missing' do
      expect_offense(<<-RUBY, 'spec/whatever.rb')
        describe MyClass do; end
        ^^^^^^^^^^^^^^^^ Spec path should end with `*_spec.rb`.
      RUBY
    end

    it 'registers an offense when a feature file is missing _spec.rb suffix' do
      expect_offense(<<-RUBY, 'spec/my_feature.rb')
        feature "my feature" do; end
        ^^^^^^^^^^^^^^^^^^^^ Spec path should end with `*_spec.rb`.
      RUBY
    end

    it 'registers an offense when the file extension is not .rb' do
      expect_offense(<<-RUBY, 'whatever_specxrb')
        describe MyClass do; end
        ^^^^^^^^^^^^^^^^ Spec path should end with `*_spec.rb`.
      RUBY
    end
  end
end
