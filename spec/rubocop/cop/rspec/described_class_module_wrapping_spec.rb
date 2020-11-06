# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DescribedClassModuleWrapping do
  it 'allows a describe block in the outermost scope' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe MyClass do
        subject { "MyClass" }
      end
    RUBY
  end

  it 'registers an offense when RSpec.describe is nested within a module' do
    expect_offense(<<-RUBY)
      module MyModule
      ^^^^^^^^^^^^^^^ Avoid opening modules and defining specs within them.
        RSpec.describe MyClass do

          subject { "MyClass" }
        end
      end
    RUBY
  end

  it 'registers an offense when RSpec.describe is nested within two modules' do
    expect_offense(<<-RUBY)
      module MyFirstModule
      ^^^^^^^^^^^^^^^^^^^^ Avoid opening modules and defining specs within them.
        module MySecondModule
        ^^^^^^^^^^^^^^^^^^^^^ Avoid opening modules and defining specs within them.
          RSpec.describe MyClass do

            subject { "MyClass" }
          end
        end
      end
    RUBY
  end

  it 'allows a module that does not contain RSpec.describe' do
    expect_no_offenses(<<-RUBY)
      module MyModule
        def some_method
        end
      end
    RUBY
  end
end
