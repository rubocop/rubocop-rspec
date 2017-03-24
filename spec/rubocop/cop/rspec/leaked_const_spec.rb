RSpec.describe RuboCop::Cop::RSpec::LeakedConst do
  subject(:cop) { described_class.new }

  it 'finds a new named class defined in-line' do
    expect_violation(<<-RUBY)
      class Foo
      ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
      end
    RUBY
  end

  it 'finds a new named class defined inside of a let block' do
    expect_violation(<<-RUBY)
      let(:fake_class) do
        class Foo
        ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
        end
      end
    RUBY
  end

  it 'finds a new named class assigned to a variable' do
    expect_violation(<<-RUBY)
      fake_class = class Foo
                   ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
      end
    RUBY
  end

  it 'finds a new unnamed class inside of a let block' do
    expect_no_violations(<<-RUBY)
      let(:fake_class) { Class.new }
    RUBY
  end

  it 'finds a new unnamed class assigned to a variable' do
    expect_no_violations(<<-RUBY)
      fake_class = Class.new
    RUBY
  end

  it 'finds a new class already marked with stub_const' do
    expect_no_violations(<<-RUBY)
      before do
        stub_const('Foo', Class.new)
        class Foo
        end
      end
    RUBY
  end

  it 'finds a new class in a module that is already marked with stub_const' do
    expect_no_violations(<<-RUBY)
      before do
        stub_const('Namespace', Module.new)
        module Namespace
          class Foo
          end
        end
      end
    RUBY
  end

  it 'finds two new classes in a module already marked with stub_const' do
    expect_no_violations(<<-RUBY)
      before do
        stub_const('Namespace::SecondNamespace', Module.new)
        module Namespace
          module SecondNamespace
            class Foo
            end

            class Bar
            end
          end
        end
      end
    RUBY
  end

  it 'finds a new class marked for stub_const after opening the class' do
    expect_violation(<<-RUBY)
      before do
        class Foo
        ^^^^^^^^^ Opening a class to define methods can pollute your tests. Instead, try using `stub_const` with an anonymized class.
        end
        stub_const('Foo', Class.new)
      end
    RUBY
  end

  it 'finds a basic test set-up using modules to open the describe block' do
    expect_no_violations(<<-RUBY)
      module TestedNamespace
        describe Subject do
        end
      end
    RUBY
  end
end
