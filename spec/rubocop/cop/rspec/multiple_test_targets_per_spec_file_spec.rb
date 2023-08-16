# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MultipleTestTargetsPerSpecFile, :config do
  it 'registers an offense when include a class and a nested class describe' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
      ^^^^^^^^^^^^^^^^^^^ Spec files should only include one test target object.
        # ...
        describe User::Admin do
        ^^^^^^^^^^^^^^^^^^^^ Spec files should only include one test target object.
          # ...
        end

        describe User::Moderator do
        ^^^^^^^^^^^^^^^^^^^^^^^^ Spec files should only include one test target object.
          # ...
        end
      end
    RUBY
  end

  it 'registers an offense when include multiple classes' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
      ^^^^^^^^^^^^^^^^^^^ Spec files should only include one test target object.
        # ...
      end

      RSpec.describe Admin do
      ^^^^^^^^^^^^^^^^^^^^ Spec files should only include one test target object.
        # ...
      end
    RUBY
  end

  it 'does not register an offense when include only class' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        describe '#method' do
          # ...
        end
      end
    RUBY
  end
end
