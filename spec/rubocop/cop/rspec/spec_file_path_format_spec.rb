# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SpecFilePathFormat, :config do
  let(:message) { "Spec path should end with `#{suffix}`." }
  let(:suffix) { 'my_class*foo*_spec.rb' }

  context 'when wrong path for describe' do
    it 'registers an offense' do
      expect_global_offense(<<~RUBY, 'wrong_path_foo_spec.rb', message)
        describe MyClass, 'foo' do; end
      RUBY
    end
  end

  context 'when wrong path for all kinds of example group' do
    it 'registers an offense' do
      expect_global_offense(<<-RUBY, 'wrong_path_foo_spec.rb', message)
        example_group MyClass, 'foo' do; end
      RUBY
    end
  end

  context 'when wrong class but a correct method' do
    it 'registers an offense' do
      expect_global_offense(<<-RUBY, 'wrong_class_foo_spec.rb', message)
        describe MyClass, '#foo' do; end
      RUBY
    end
  end

  context 'when wrong class and highlights metadata' do
    it 'registers an offense' do
      expect_global_offense(<<-RUBY, 'wrong_class_foo_spec.rb', message)
        describe MyClass, '#foo', blah: :blah do; end
      RUBY
    end
  end

  context 'when wrong class name' do
    let(:suffix) { 'my_class*_spec.rb' }

    it 'registers an offense' do
      expect_global_offense(<<-RUBY, 'wrong_class_spec.rb', message)
        describe MyClass do; end
      RUBY
    end
  end

  context 'when wrong class name with a symbol argument' do
    let(:suffix) { 'my_class*_spec.rb' }

    it 'registers an offense' do
      expect_global_offense(<<-RUBY, 'wrong_class_spec.rb', message)
        describe MyClass, :foo do; end
      RUBY
    end
  end

  context 'when second argument contains spaces' do
    let(:suffix) { 'my_class*via_local_failures*_spec.rb' }

    it 'registers an offense' do
      expect_global_offense(<<-RUBY, 'wrong_class_spec.rb', message)
        describe MyClass, "via `local_failures`" do; end
      RUBY
    end
  end

  context 'when only shared examples' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'spec/models/user.rb')
        shared_examples_for 'foo' do; end
      RUBY
    end
  end

  context 'when example groups do not describe a class/method' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class/spec.rb')
        describe 'Test something' do; end
      RUBY
    end
  end

  context 'when multiple top level describes' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class/spec.rb')
        describe MyClass, 'do_this' do; end
        describe MyClass, 'do_that' do; end
      RUBY
    end
  end

  context 'when class specs' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class_spec.rb')
        describe Some::Class do; end
      RUBY
    end
  end

  context 'when different parent directories' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'parent_dir/some/class_spec.rb')
        describe Some::Class do; end
      RUBY
    end
  end

  context 'when CamelCaps class names' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'my_class_spec.rb')
        describe MyClass do; end
      RUBY
    end
  end

  context 'when ACRONYMClassNames' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'abc_one/two_spec.rb')
        describe ABCOne::Two do; end
      RUBY
    end
  end

  context 'when ALLCAPS class names' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'allcaps_spec.rb')
        describe ALLCAPS do; end
      RUBY
    end
  end

  context 'when alphanumeric class names' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'ipv4_and_ipv6_spec.rb')
        describe IPV4AndIPV6 do; end
      RUBY
    end
  end

  context 'when instance methods' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class/inst_spec.rb')
        describe Some::Class, '#inst' do; end
      RUBY
    end
  end

  context 'when class methods' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class/inst_spec.rb')
        describe Some::Class, '.inst' do; end
      RUBY
    end
  end

  context 'when flat hierarchies for instance methods' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class_inst_spec.rb')
        describe Some::Class, '#inst' do; end
      RUBY
    end
  end

  context 'when flat hierarchies for class methods' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class_inst_spec.rb')
        describe Some::Class, '.inst' do; end
      RUBY
    end
  end

  context 'when subdirs for instance methods' do
    it 'does not register an offense' do
      filename = 'some/class/instance_methods/inst_spec.rb'
      expect_no_global_offenses(<<-RUBY, filename)
        describe Some::Class, '#inst' do; end
      RUBY
    end
  end

  context 'when subdirs for class methods' do
    it 'does not register an offense' do
      filename = 'some/class/class_methods/inst_spec.rb'
      expect_no_global_offenses(<<-RUBY, filename)
        describe Some::Class, '.inst' do; end
      RUBY
    end
  end

  context 'when non-alphanumeric characters' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class/pred_spec.rb')
        describe Some::Class, '#pred?' do; end
      RUBY
    end
  end

  context 'when bang method' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'some/class/bang_spec.rb')
        describe Some::Class, '#bang!' do; end
      RUBY
    end
  end

  context 'when an arbitrary spec suffix' do
    it 'does not register an offense' do
      filename = 'some/class/thing_predicate_spec.rb'
      expect_no_global_offenses(<<-RUBY, filename)
        describe Some::Class, '#thing?' do; end
      RUBY
    end
  end

  context 'when an arbitrary spec name for an operator method' do
    it 'does not register an offense' do
      filename = 'my_little_class/spaceship_operator_spec.rb'
      expect_no_global_offenses(<<-RUBY, filename)
        describe MyLittleClass, '#<=>' do; end
      RUBY
    end
  end

  context 'when path containing the class name' do
    let(:suffix) { 'foo*_spec.rb' }

    it 'registers an offense' do
      filename = '/home/foo/spec/models/bar_spec.rb'
      expect_global_offense(<<-RUBY, filename, message)
        describe Foo do; end
      RUBY
    end
  end

  context 'when path with incorrect collapsed namespace' do
    let(:suffix) { 'very/long/namespace/my_class*_spec.rb' }

    it 'registers an offense' do
      filename = '/home/foo/spec/very/my_class_spec.rb'
      expect_global_offense(<<-RUBY, filename, message)
        describe Very::Long::Namespace::MyClass do; end
      RUBY
    end
  end

  context 'when path with incorrect expanded namespace' do
    let(:suffix) { 'very/medium/my_class*_spec.rb' }

    it 'registers an offense' do
      filename = '/home/foo/spec/very/long/my_class_spec.rb'
      expect_global_offense(<<-RUBY, filename, message)
        module Very
          module Medium
            describe MyClass do; end
          end
        end
      RUBY
    end
  end

  context 'when absolute file path' do
    it 'does not register offense' do
      # RuboCop's Commissioner is calling it, too
      allow(File).to receive(:expand_path).and_call_original
      allow(File).to receive(:expand_path).with('my_class_spec.rb').and_return(
        '/home/foo/spec/very/long/namespace/my_class_spec.rb'
      )
      expect_no_global_offenses(<<-RUBY, 'my_class_spec.rb')
        describe Very::Long::Namespace::MyClass do; end
      RUBY
    end
  end

  context 'when files defining an empty class' do
    # RSpec/FilePath runs on all files - not only **/*_spec.rb
    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY)
        class Foo
        end
      RUBY
    end
  end

  context 'when path is under spec/routing and it ends with _spec.rb' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<~RUBY, 'spec/routing/foo_spec.rb')
        describe 'routes to the foo controller' do; end
      RUBY
    end
  end

  context 'when `type: :routing` is used and it ends with _spec.rb' do
    it 'does not register an offense' do
      expect_no_global_offenses(<<~RUBY, 'spec/foo_spec.rb')
        describe 'routes to the foo controller', type: :routing do; end
      RUBY
    end
  end

  context 'when configured with `CustomTransform: { "FooFoo" => "foofoo" }`' do
    let(:cop_config) { { 'CustomTransform' => { 'FooFoo' => 'foofoo' } } }

    it 'does not register an offense for custom module name transformation' do
      expect_no_global_offenses(<<-RUBY, 'foofoo/some/class/bar_spec.rb')
        describe FooFoo::Some::Class, '#bar' do; end
      RUBY
    end
  end

  context 'when configured with `IgnoreMethods: false`' do
    let(:cop_config) { { 'IgnoreMethods' => false } }
    let(:suffix) { 'my_class*look_here_a_method*_spec.rb' }

    context 'when file path not include method name' do
      it 'registers an offense' do
        expect_global_offense(<<-RUBY, 'my_class_spec.rb', message)
          describe MyClass, '#look_here_a_method' do; end
        RUBY
      end
    end
  end

  context 'when configured with `IgnoreMethods: true`' do
    let(:cop_config) { { 'IgnoreMethods' => true } }

    context 'when file path not include method name' do
      it 'does not register an offense' do
        expect_no_global_offenses(<<-RUBY, 'my_class_spec.rb')
          describe MyClass, '#look_here_a_method' do; end
        RUBY
      end
    end
  end

  context 'when configured with `IgnoreMetadata: { "foo" => "bar" }`' do
    let(:cop_config) { { 'IgnoreMetadata' => { 'foo' => 'bar' } } }

    it 'does not register an offense' do
      expect_no_global_offenses(<<-RUBY, 'wrong_class_spec.rb')
        describe MyClass, foo: :bar do; end
      RUBY
    end
  end
end
