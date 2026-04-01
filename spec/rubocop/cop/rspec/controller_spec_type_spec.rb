# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ControllerSpecType do
  it 'flags `type: :controller` metadata' do
    expect_offense(<<~RUBY)
      RSpec.describe UsersController, type: :controller do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Controller specs are deprecated. Use request specs (`type: :request`) instead.
        it 'does something' do
        end
      end
    RUBY
  end

  it 'flags `type: :controller` with additional metadata' do
    expect_offense(<<~RUBY)
      RSpec.describe UsersController, type: :controller, focus: true do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Controller specs are deprecated. Use request specs (`type: :request`) instead.
        it 'does something' do
        end
      end
    RUBY
  end

  it 'does not flag `type: :request`' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'Users', type: :request do
        it 'does something' do
        end
      end
    RUBY
  end

  it 'does not flag describe without type metadata' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        it 'does something' do
        end
      end
    RUBY
  end

  it 'does not flag describe with no arguments' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe do
        it 'does something' do
        end
      end
    RUBY
  end
end
