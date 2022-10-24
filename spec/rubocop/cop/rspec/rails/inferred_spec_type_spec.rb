# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::InferredSpecType do
  describe 'with necessary type in keyword arguments' do
    it 'does not register any offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User, type: :model do
        end
      RUBY
    end
  end

  describe 'with redundant type in keyword arguments' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        RSpec.describe User, type: :model do
                             ^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
        end
      RUBY
    end
  end

  describe 'with redundant type in Hash arguments' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        RSpec.describe User, { type: :model } do
                             ^^^^^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
        end
      RUBY
    end
  end

  describe 'with redundant type before other Hash metadata' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        RSpec.describe User, type: :model, other: true do
                             ^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User, other: true do
        end
      RUBY
    end
  end

  describe 'with redundant type after other Hash metadata' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        RSpec.describe User, other: true, type: :model do
                                          ^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User, other: true do
        end
      RUBY
    end
  end

  describe 'with redundant type and other Symbol metadata' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        RSpec.describe User, :other, type: :model do
                                     ^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User, :other do
        end
      RUBY
    end
  end

  describe 'with redundant type and receiver-less describe' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        describe User, type: :model do
                       ^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        describe User do
        end
      RUBY
    end
  end

  describe 'with redundant type in inner example group' do
    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/models/user_spec.rb')
        RSpec.describe User do
          describe 'inner', type: :model do
                            ^^^^^^^^^^^^ Remove redundant spec type.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          describe 'inner' do
          end
        end
      RUBY
    end
  end

  describe 'with a type not on the list' do
    it 'register and corrects an offense' do
      expect_no_offenses(<<~RUBY, '/path/to/project/spec/alerts/red_spec.rb')
        RSpec.describe Red, type: :alert do
        end
      RUBY
    end
  end

  describe 'with a Rails routing type' do
    it 'register and corrects an offense' do
      expect_no_offenses(<<~RUBY, '/project/spec/routing/my_routing_spec.rb')
        RSpec.describe Red, type: :routing do
        end
      RUBY
    end
  end

  describe 'with Inferences configuration' do
    let(:cop_config) do
      {
        'Inferences' => {
          'services' => 'service'
        }
      }
    end

    it 'register and corrects an offense' do
      expect_offense(<<~RUBY, '/path/to/project/spec/services/user_spec.rb')
        RSpec.describe User, type: :service do
                             ^^^^^^^^^^^^^^ Remove redundant spec type.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
        end
      RUBY
    end
  end
end
