# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DescribeClass, :config do
  it 'checks first-line describe statements' do
    expect_offense(<<-RUBY)
      describe "bad describe" do
               ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'supports RSpec.describe' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
      end
    RUBY
  end

  it 'supports ::RSpec.describe' do
    expect_no_offenses(<<-RUBY)
      ::RSpec.describe Foo do
      end
    RUBY
  end

  it 'checks describe statements after a require' do
    expect_offense(<<-RUBY)
      require 'spec_helper'
      describe "bad describe" do
               ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'checks highlights the first argument of a describe' do
    expect_offense(<<-RUBY)
      describe "bad describe", "blah blah" do
               ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'ignores nested describe statements' do
    expect_no_offenses(<<-RUBY)
      describe Some::Class do
        describe "bad describe" do
        end
      end
    RUBY
  end

  context 'when argument is a String literal' do
    it 'ignores class without namespace' do
      expect_no_offenses(<<-RUBY)
        describe 'Thing' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores class with namespace' do
      expect_no_offenses(<<-RUBY)
        describe 'Some::Thing' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores value constants' do
      expect_no_offenses(<<-RUBY)
        describe 'VERSION' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores value constants with namespace' do
      expect_no_offenses(<<-RUBY)
        describe 'Some::VERSION' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores top-level constants with `::` at start' do
      expect_no_offenses(<<-RUBY)
        describe '::Some::VERSION' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'checks `camelCase`' do
      expect_offense(<<-RUBY)
        describe 'activeRecord' do
                 ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'checks numbers at start' do
      expect_offense(<<-RUBY)
        describe '2Thing' do
                 ^^^^^^^^ The first argument to describe should be the class or module being tested.
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'checks empty strings' do
      expect_offense(<<-RUBY)
        describe '' do
                 ^^ The first argument to describe should be the class or module being tested.
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end
  end

  it 'ignores an empty describe' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe do
      end

      describe do
      end
    RUBY
  end

  it "doesn't flag top level describe in a shared example" do
    expect_no_offenses(<<-RUBY)
      shared_examples 'Common::Interface' do
        describe '#public_interface' do
          it 'conforms to interface' do
            # ...
          end
        end
      end
    RUBY
  end

  it "doesn't flag top level describe in a shared context" do
    expect_no_offenses(<<-RUBY)
      RSpec.shared_context 'Common::Interface' do
        describe '#public_interface' do
          it 'conforms to interface' do
            # ...
          end
        end
      end
    RUBY
  end

  it "doesn't flag top level describe in an unnamed shared context" do
    expect_no_offenses(<<-RUBY)
      shared_context do
        describe '#public_interface' do
          it 'conforms to interface' do
            # ...
          end
        end
      end
    RUBY
  end

  it 'ignores `type` metadata ignored by default' do
    expect_no_offenses(<<-RUBY)
      describe 'widgets/index', type: :view do
      end
    RUBY
  end

  it 'flags specs with non `type` metadata' do
    expect_offense(<<-RUBY)
      describe 'foo bar', foo: :bar do
               ^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'ignores feature specs - also with complex options' do
    expect_no_offenses(<<-RUBY)
      describe 'my new feature', :test, foo: :bar, type: :feature do
      end
    RUBY
  end

  it 'flags non-ignored `type` metadata' do
    expect_offense(<<-RUBY)
      describe 'wow', blah, type: :wow do
               ^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  context 'when IgnoredMetadata is configured' do
    let(:cop_config) do
      { 'IgnoredMetadata' =>
        { 'foo' => ['bar'],
          'type' => ['wow'] } }
    end

    it 'ignores configured metadata' do
      expect_no_offenses(<<-RUBY)
        describe 'foo bar', foo: :bar do
        end
      RUBY
    end

    it 'ignores configured `type` metadata' do
      expect_no_offenses(<<-RUBY)
        describe 'my new system test', type: :wow do
        end
      RUBY
    end
  end
end
