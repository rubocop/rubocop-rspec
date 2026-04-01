# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ControllerSpecDirectory do
  it 'flags `RSpec.describe` with a constant in controllers directory' do
    expect_offense(<<~RUBY, 'spec/controllers/users_controller_spec.rb')
      RSpec.describe UsersController do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Controller spec directories are deprecated. Move specs to `spec/requests/` and use `type: :request`.
        it 'does something' do
        end
      end
    RUBY
  end

  it 'flags `RSpec.describe` with a string in controllers directory' do
    expect_offense(<<~RUBY, 'spec/controllers/users_controller_spec.rb')
      RSpec.describe 'UsersController' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Controller spec directories are deprecated. Move specs to `spec/requests/` and use `type: :request`.
        it 'does something' do
        end
      end
    RUBY
  end

  it 'flags `RSpec.describe` in a nested controllers directory' do
    filename = 'packs/admin/spec/controllers/companies_controller_spec.rb'
    expect_offense(<<~RUBY, filename)
      RSpec.describe CompaniesController do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Controller spec directories are deprecated. Move specs to `spec/requests/` and use `type: :request`.
        it 'does something' do
        end
      end
    RUBY
  end

  it 'does not flag specs outside controllers directory' do
    expect_no_offenses(<<~RUBY, 'spec/requests/users_spec.rb')
      RSpec.describe 'Users', type: :request do
        it 'does something' do
        end
      end
    RUBY
  end
end
