# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SpecFilePathFormat, :config do
  it 'registers an offense when wrong path for describe' do
    expect_offense(<<~RUBY, 'wrong_path_foo_spec.rb')
      describe MyClass, 'foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense when wrong path for all kinds of example group' do
    expect_offense(<<~RUBY, 'wrong_path_foo_spec.rb')
      example_group MyClass, 'foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense when wrong class but a correct method' do
    expect_offense(<<~RUBY, 'wrong_class_foo_spec.rb')
      describe MyClass, '#foo' do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense when wrong class and highlights metadata' do
    expect_offense(<<~RUBY, 'wrong_class_foo_spec.rb')
      describe MyClass, '#foo', blah: :blah do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense when wrong class name' do
    expect_offense(<<~RUBY, 'wrong_class_spec.rb')
      describe MyClass do; end
      ^^^^^^^^^^^^^^^^ Spec path should end with `my_class*_spec.rb`.
    RUBY
  end

  it 'registers an offense when wrong top-level class name' do
    expect_offense(<<~RUBY, 'wrong_class_spec.rb')
      describe ::MyClass do; end
      ^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*_spec.rb`.
    RUBY
  end

  it 'registers an offense when wrong class name with a symbol argument' do
    expect_offense(<<~RUBY, 'wrong_class_spec.rb')
      describe MyClass, :foo do; end
      ^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*_spec.rb`.
    RUBY
  end

  it 'registers an offense when second argument contains spaces' do
    expect_offense(<<~RUBY, 'wrong_class_spec.rb')
      describe MyClass, "via `local_failures`" do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*via_local_failures*_spec.rb`.
    RUBY
  end

  it 'does not register an offense when only shared examples' do
    expect_no_offenses(<<~RUBY, 'spec/models/user.rb')
      shared_examples_for 'foo' do; end
    RUBY
  end

  it 'does not register an offense when example groups do not describe ' \
     'a class/method' do
    expect_no_offenses(<<~RUBY, 'some/class/spec.rb')
      describe 'Test something' do; end
    RUBY
  end

  it 'does not register an offense when multiple top level describes' do
    expect_no_offenses(<<~RUBY, 'some/class/spec.rb')
      describe MyClass, 'do_this' do; end
      describe MyClass, 'do_that' do; end
    RUBY
  end

  it 'does not register an offense when class specs' do
    expect_no_offenses(<<~RUBY, 'some/class_spec.rb')
      describe Some::Class do; end
    RUBY
  end

  it 'does not register an offense when different parent directories' do
    expect_no_offenses(<<~RUBY, 'parent_dir/some/class_spec.rb')
      describe Some::Class do; end
    RUBY
  end

  it 'does not register an offense when CamelCaps class names' do
    expect_no_offenses(<<~RUBY, 'my_class_spec.rb')
      describe MyClass do; end
    RUBY
  end

  it 'does not register an offense when ACRONYMClassNames' do
    expect_no_offenses(<<~RUBY, 'abc_one/two_spec.rb')
      describe ABCOne::Two do; end
    RUBY
  end

  it 'does not register an offense when ALLCAPS class names' do
    expect_no_offenses(<<~RUBY, 'allcaps_spec.rb')
      describe ALLCAPS do; end
    RUBY
  end

  it 'does not register an offense when alphanumeric class names' do
    expect_no_offenses(<<~RUBY, 'ipv4_and_ipv6_spec.rb')
      describe IPV4AndIPV6 do; end
    RUBY
  end

  it 'does not register an offense when instance methods' do
    expect_no_offenses(<<~RUBY, 'some/class/inst_spec.rb')
      describe Some::Class, '#inst' do; end
    RUBY
  end

  it 'does not register an offense when class methods' do
    expect_no_offenses(<<~RUBY, 'some/class/inst_spec.rb')
      describe Some::Class, '.inst' do; end
    RUBY
  end

  it 'does not register an offense when flat hierarchies for ' \
     'instance methods' do
    expect_no_offenses(<<~RUBY, 'some/class_inst_spec.rb')
      describe Some::Class, '#inst' do; end
    RUBY
  end

  it 'does not register an offense when flat hierarchies for class methods' do
    expect_no_offenses(<<~RUBY, 'some/class_inst_spec.rb')
      describe Some::Class, '.inst' do; end
    RUBY
  end

  it 'does not register an offense when subdirs for instance methods' do
    filename = 'some/class/instance_methods/inst_spec.rb'
    expect_no_offenses(<<~RUBY, filename)
      describe Some::Class, '#inst' do; end
    RUBY
  end

  it 'does not register an offense when subdirs for class methods' do
    filename = 'some/class/class_methods/inst_spec.rb'
    expect_no_offenses(<<~RUBY, filename)
      describe Some::Class, '.inst' do; end
    RUBY
  end

  it 'does not register an offense when non-alphanumeric characters' do
    expect_no_offenses(<<~RUBY, 'some/class/pred_spec.rb')
      describe Some::Class, '#pred?' do; end
    RUBY
  end

  it 'does not register an offense when bang method' do
    expect_no_offenses(<<~RUBY, 'some/class/bang_spec.rb')
      describe Some::Class, '#bang!' do; end
    RUBY
  end

  it 'does not register an offense when an arbitrary spec suffix' do
    filename = 'some/class/thing_predicate_spec.rb'
    expect_no_offenses(<<~RUBY, filename)
      describe Some::Class, '#thing?' do; end
    RUBY
  end

  it 'does not register an offense when an arbitrary spec name for ' \
     'an operator method' do
    filename = 'my_little_class/spaceship_operator_spec.rb'
    expect_no_offenses(<<~RUBY, filename)
      describe MyLittleClass, '#<=>' do; end
    RUBY
  end

  it 'registers an offense when path containing the class name' do
    filename = '/home/foo/spec/models/bar_spec.rb'
    expect_offense(<<~RUBY, filename)
      describe Foo do; end
      ^^^^^^^^^^^^ Spec path should end with `foo*_spec.rb`.
    RUBY
  end

  it 'registers an offense when path with incorrect collapsed namespace' do
    filename = '/home/foo/spec/very/my_class_spec.rb'
    expect_offense(<<~RUBY, filename)
      describe Very::Long::Namespace::MyClass do; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `very/long/namespace/my_class*_spec.rb`.
    RUBY
  end

  it 'registers an offense when path with incorrect expanded namespace' do
    filename = '/home/foo/spec/very/long/my_class_spec.rb'
    expect_offense(<<~RUBY, filename)
      module Very
        module Medium
          describe MyClass do; end
          ^^^^^^^^^^^^^^^^ Spec path should end with `very/medium/my_class*_spec.rb`.
        end
      end
    RUBY
  end

  it 'does not register offense when absolute file path' do
    # RuboCop's Commissioner is calling it, too
    allow(File).to receive(:expand_path).and_call_original
    allow(File).to receive(:expand_path).with('my_class_spec.rb').and_return(
      '/home/foo/spec/very/long/namespace/my_class_spec.rb'
    )
    expect_no_offenses(<<~RUBY, 'my_class_spec.rb')
      describe Very::Long::Namespace::MyClass do; end
    RUBY
  end

  # RSpec/FilePath runs on all files - not only **/*_spec.rb
  it 'does not register an offense when files defining an empty class' do
    expect_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  end

  it 'does not register an offense when path is under spec/routing and ' \
     'it ends with _spec.rb' do
    expect_no_offenses(<<~RUBY, 'spec/routing/foo_spec.rb')
      describe 'routes to the foo controller' do; end
    RUBY
  end

  it 'does not register an offense when `type: :routing` is used and ' \
     'it ends with _spec.rb' do
    expect_no_offenses(<<~RUBY, 'spec/foo_spec.rb')
      describe 'routes to the foo controller', type: :routing do; end
    RUBY
  end

  context 'when configured with `CustomTransform: { "FooFoo" => "foofoo" }`' do
    let(:cop_config) { { 'CustomTransform' => { 'FooFoo' => 'foofoo' } } }

    it 'does not register an offense for custom module name transformation' do
      expect_no_offenses(<<~RUBY, 'foofoo/some/class/bar_spec.rb')
        describe FooFoo::Some::Class, '#bar' do; end
      RUBY
    end
  end

  context 'when configured with `IgnoreMethods: false`' do
    let(:cop_config) { { 'IgnoreMethods' => false } }
    let(:suffix) { 'my_class*look_here_a_method*_spec.rb' }

    it 'registers an offense when file path not include method name' do
      expect_offense(<<~RUBY, 'my_class_spec.rb')
        describe MyClass, '#look_here_a_method' do; end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Spec path should end with `my_class*look_here_a_method*_spec.rb`.
      RUBY
    end
  end

  context 'when configured with `IgnoreMethods: true`' do
    let(:cop_config) { { 'IgnoreMethods' => true } }

    it 'does not register an offense when file path not include method name' do
      expect_no_offenses(<<~RUBY, 'my_class_spec.rb')
        describe MyClass, '#look_here_a_method' do; end
      RUBY
    end
  end

  context 'when configured with `IgnoreMetadata: { "foo" => "bar" }`' do
    let(:cop_config) { { 'IgnoreMetadata' => { 'foo' => 'bar' } } }

    it 'does not register an offense when include ignored metadata' do
      expect_no_offenses(<<~RUBY, 'wrong_class_spec.rb')
        describe MyClass, foo: :bar do; end
      RUBY
    end
  end
end
