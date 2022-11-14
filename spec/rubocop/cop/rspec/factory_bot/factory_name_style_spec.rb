# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::FactoryNameStyle,
               :config do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'when EnforcedStyle is :symbol' do
    let(:enforced_style) { :symbol }

    it 'registers an offense when using `create` with string name' do
      expect_offense(<<~RUBY)
        create('user')
               ^^^^^^ Use symbol to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        create(:user)
      RUBY
    end

    it 'registers an offense when using `create` with string name and ' \
       'multiline method calls' do
      expect_offense(<<~RUBY)
        create('user',
               ^^^^^^ Use symbol to refer to a factory.
          username: "PETER",
          peter: "USERNAME")
      RUBY

      expect_correction(<<~RUBY)
        create(:user,
          username: "PETER",
          peter: "USERNAME")
      RUBY
    end

    it 'registers an offense when using `build` with string name' do
      expect_offense(<<~RUBY)
        build 'user'
              ^^^^^^ Use symbol to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        build :user
      RUBY
    end

    it 'registers an offense when using `create` with an explicit receiver' do
      expect_offense(<<~RUBY)
        FactoryBot.create('user')
                          ^^^^^^ Use symbol to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        FactoryBot.create(:user)
      RUBY
    end

    it 'does not register an offense when using `create` with symbol name`' do
      expect_no_offenses(<<~RUBY)
        create(:user)
      RUBY
    end

    it 'does not register an offense when using `build` with symbol name`' do
      expect_no_offenses(<<~RUBY)
        build(:user)
      RUBY
    end

    it 'does not register an offense when using `create` ' \
       'with string interpolation name`' do
      expect_no_offenses(<<~RUBY)
        create("user_\#{type}")
      RUBY
    end

    it 'does not register an offense when using `build` ' \
       'with string interpolation name`' do
      expect_no_offenses(<<~RUBY)
        build("user_\#{'a'}")
      RUBY
    end

    it 'does not register an offense when using `create` ' \
       'with keyword argument' do
      expect_no_offenses(<<~RUBY)
        create user: :foo
      RUBY
    end

    it 'does not register an offense when using `build` ' \
       'with keyword argument' do
      expect_no_offenses(<<~RUBY)
        build user: :foo
      RUBY
    end
  end

  context 'when EnforcedStyle is :string' do
    let(:enforced_style) { :string }

    it 'registers an offense when using `create` with symbol name' do
      expect_offense(<<~RUBY)
        create(:user)
               ^^^^^ Use string to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        create("user")
      RUBY
    end

    it 'registers an offense when using `create` with symbol name and ' \
       'multiline method calls' do
      expect_offense(<<~RUBY)
        create(:user,
               ^^^^^ Use string to refer to a factory.
          username: "PETER",
          peter: "USERNAME")
      RUBY

      expect_correction(<<~RUBY)
        create("user",
          username: "PETER",
          peter: "USERNAME")
      RUBY
    end

    it 'registers an offense when using `build` with symbol name' do
      expect_offense(<<~RUBY)
        build :user
              ^^^^^ Use string to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        build "user"
      RUBY
    end

    it 'registers an offense when using `create` with an explicit receiver' do
      expect_offense(<<~RUBY)
        FactoryBot.create(:user)
                          ^^^^^ Use string to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        FactoryBot.create("user")
      RUBY
    end

    it 'registers an offense when using `create` with a method call' do
      expect_offense(<<~RUBY)
        do_something create(:user)
                            ^^^^^ Use string to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        do_something create("user")
      RUBY
    end

    it 'registers an offense when using `build` with a method call' do
      expect_offense(<<~RUBY)
        do_something build(:user)
                           ^^^^^ Use string to refer to a factory.
      RUBY

      expect_correction(<<~RUBY)
        do_something build("user")
      RUBY
    end

    it 'does not register an offense when using `create` with string name`' do
      expect_no_offenses(<<~RUBY)
        create('user')
      RUBY
    end

    it 'does not register an offense when using `build` with string name`' do
      expect_no_offenses(<<~RUBY)
        build('user')
      RUBY
    end

    it 'does not register an offense when using `create` ' \
       'with a local variable' do
      expect_no_offenses(<<~RUBY)
        create(user)
      RUBY
    end

    it 'does not register an offense when using `build` ' \
       'with a local variable' do
      expect_no_offenses(<<~RUBY)
        build(user)
      RUBY
    end

    it 'does not register an offense when using `create` ' \
       'with string interpolation name`' do
      expect_no_offenses(<<~RUBY)
        create("user_\#{type}")
      RUBY
    end

    it 'does not register an offense when using `build` ' \
       'with string interpolation name`' do
      expect_no_offenses(<<~RUBY)
        build("user_\#{'a'}")
      RUBY
    end

    it 'does not register an offense when using `create` ' \
       'with keyword argument' do
      expect_no_offenses(<<~RUBY)
        create user: :foo
      RUBY
    end

    it 'does not register an offense when using `build` ' \
       'with keyword argument' do
      expect_no_offenses(<<~RUBY)
        build user: :foo
      RUBY
    end
  end
end
