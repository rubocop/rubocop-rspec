# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterSharedInclusion do
  %w[include_context include_examples it_behaves_like
     it_should_behave_like].each do |method|
    it "registers an offense for code that immediately follows #{method}" do
      expect_offense(<<~RUBY, method: method)
        RSpec.describe User do
          %{method} 'examples'
          ^{method}^^^^^^^^^^^ Add an empty line after shared example inclusion.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          #{method} 'examples'

          it { does_something }
        end
      RUBY
    end

    it "registers an offense for #{method} followed by a comment" do
      expect_offense(<<~RUBY, method: method)
        RSpec.describe User do
          %{method} 'examples'
          ^{method}^^^^^^^^^^^ Add an empty line after shared example inclusion.
          # my comment
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          #{method} 'examples'

          # my comment
          it { does_something }
        end
      RUBY
    end

    it "registers an offense for #{method} and `rubocop:enable` comment line" do
      expect_offense(<<~RUBY, method: method)
        RSpec.describe User do
          # rubocop:disable RSpec/Foo
          %{method} 'examples'
          # rubocop:enable RSpec/Foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after shared example inclusion.
          it { does_something }
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe User do
          # rubocop:disable RSpec/Foo
          #{method} 'examples'
          # rubocop:enable RSpec/Foo

          it { does_something }
        end
      RUBY
    end

    it "does not register an offense for #{method} with a newline" do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          #{method} 'examples'

          it { does_something }
        end
      RUBY
    end

    it "does not register an offense when #{method} is the last node" do
      expect_no_offenses(<<~RUBY)
        RSpec.describe User do
          #{method} 'examples'
        end
      RUBY
    end
  end

  it 'does not register an offense for grouped inclusions' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        include_context 'with_authentication'
        include_context 'with_authorization'

        it { does_something }
      end
    RUBY
  end

  it 'does not register an offense for mixed grouped inclusions' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        include_context 'with_authentication'
        it_behaves_like 'a sortable'
        include_examples 'common validations'

        it { does_something }
      end
    RUBY
  end

  it 'registers an offense only for the last inclusion in a group' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        include_context 'with_authentication'
        include_context 'with_authorization'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after shared example inclusion.
        it { does_something }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        include_context 'with_authentication'
        include_context 'with_authorization'

        it { does_something }
      end
    RUBY
  end

  it 'registers an offense in nested example groups' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        context 'when admin' do
          include_context 'with_admin_role'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after shared example inclusion.
          it { does_something }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe User do
        context 'when admin' do
          include_context 'with_admin_role'

          it { does_something }
        end
      end
    RUBY
  end

  it 'registers an offense inside shared_examples' do
    expect_offense(<<~RUBY)
      RSpec.shared_examples 'sortable' do
        include_context 'with_sorting'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after shared example inclusion.
        it { does_something }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.shared_examples 'sortable' do
        include_context 'with_sorting'

        it { does_something }
      end
    RUBY
  end

  it 'registers an offense inside shared_context' do
    expect_offense(<<~RUBY)
      shared_context 'with_user' do
        include_context 'with_authentication'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after shared example inclusion.
        let(:user) { create(:user) }
      end
    RUBY

    expect_correction(<<~RUBY)
      shared_context 'with_user' do
        include_context 'with_authentication'

        let(:user) { create(:user) }
      end
    RUBY
  end

  it 'does not register an offense when inclusion is the last child' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        it { does_something }
        include_context 'with_authentication'
      end
    RUBY
  end

  it 'does not register an offense outside of an example group' do
    expect_no_offenses(<<~RUBY)
      include_context 'examples'
      foo
    RUBY
  end

  it 'does not register an offense for a single body node' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        include_context 'with_authentication'
      end
    RUBY
  end
end
