# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::HookArgument do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  shared_examples 'ignored hooks' do
    it 'ignores :context and :suite' do
      expect_no_offenses(<<~RUBY)
        before(:suite) { true }
        after(:suite) { true }
        before(:context) { true }
        after(:context) { true }
      RUBY
    end

    it 'ignores hooks with more than one argument' do
      expect_no_offenses(<<~RUBY)
        before(:each, :something_custom) { true }
      RUBY
    end

    it 'ignores non-rspec hooks' do
      expect_no_offenses(<<~RUBY)
        setup(:each) { true }
      RUBY
    end
  end

  shared_examples 'an example hook' do
    include_examples 'ignored hooks'
    include_examples 'detects style', 'before(:each) { foo }', 'each'
    include_examples 'detects style', 'before(:example) { foo }', 'example'
    include_examples 'detects style', 'before { foo }', 'implicit'
  end

  context 'when EnforcedStyle is :implicit' do
    let(:enforced_style) { :implicit }

    it 'detects :each for hooks' do
      expect_offense(<<~RUBY)
        before(:each) { true }
        ^^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
        after(:each) { true }
        ^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
        around(:each) { true }
        ^^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
        config.after(:each) { true }
        ^^^^^^^^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
      RUBY

      expect_correction(<<~RUBY)
        before { true }
        after { true }
        around { true }
        config.after { true }
      RUBY
    end

    it 'detects :example for hooks' do
      expect_offense(<<~RUBY)
        before(:example) { true }
        ^^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
        after(:example) { true }
        ^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
        around(:example) { true }
        ^^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
        config.before(:example) { true }
        ^^^^^^^^^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
      RUBY

      expect_correction(<<~RUBY)
        before { true }
        after { true }
        around { true }
        config.before { true }
      RUBY
    end

    it 'does not flag hooks without default scopes' do
      expect_no_offenses(<<~RUBY)
        before { true }
        after { true }
        around { true }
        config.before { true }
      RUBY
    end

    include_examples 'an example hook'

    context 'when Ruby 2.7', :ruby27 do
      it 'detects :each for hooks' do
        expect_offense(<<~RUBY)
          around(:each) { _1 }
          ^^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
        RUBY

        expect_correction(<<~RUBY)
          around { _1 }
        RUBY
      end

      it 'detects :example for hooks' do
        expect_offense(<<~RUBY)
          around(:example) { _1 }
          ^^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
        RUBY

        expect_correction(<<~RUBY)
          around { _1 }
        RUBY
      end

      it 'does not flag hooks without default scopes' do
        expect_no_offenses(<<~RUBY)
          around { _1 }
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is :each' do
    let(:enforced_style) { :each }

    it 'does not flag :each for hooks' do
      expect_no_offenses(<<~RUBY)
        before(:each) { true }
        after(:each) { true }
        around(:each) { true }
        config.before(:each) { true }
      RUBY
    end

    it 'detects :example for hooks' do
      expect_offense(<<~RUBY)
        before(:example) { true }
        ^^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
        after(:example) { true }
        ^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
        around(:example) { true }
        ^^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
        config.before(:example) { true }
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
      RUBY

      expect_correction(<<~RUBY)
        before(:each) { true }
        after(:each) { true }
        around(:each) { true }
        config.before(:each) { true }
      RUBY
    end

    it 'detects hooks without default scopes' do
      expect_offense(<<~RUBY)
        before { true }
        ^^^^^^ Use `:each` for RSpec hooks.
        after { true }
        ^^^^^ Use `:each` for RSpec hooks.
        around { true }
        ^^^^^^ Use `:each` for RSpec hooks.
        config.before { true }
               ^^^^^^ Use `:each` for RSpec hooks.
      RUBY

      expect_correction(<<~RUBY)
        before(:each) { true }
        after(:each) { true }
        around(:each) { true }
        config.before(:each) { true }
      RUBY
    end

    include_examples 'an example hook'

    context 'when Ruby 2.7', :ruby27 do
      it 'does not flag :each for hooks' do
        expect_no_offenses(<<~RUBY)
          around(:each) { _1 }
        RUBY
      end

      it 'detects :example for hooks' do
        expect_offense(<<~RUBY)
          around(:example) { _1 }
          ^^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
        RUBY

        expect_correction(<<~RUBY)
          around(:each) { _1 }
        RUBY
      end

      it 'detects hooks without default scopes' do
        expect_offense(<<~RUBY)
          around { _1 }
          ^^^^^^ Use `:each` for RSpec hooks.
        RUBY

        expect_correction(<<~RUBY)
          around(:each) { _1 }
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is :example' do
    let(:enforced_style) { :example }

    it 'does not flag :example for hooks' do
      expect_no_offenses(<<~RUBY)
        before(:example) { true }
        after(:example) { true }
        around(:example) { true }
        config.before(:example) { true }
      RUBY
    end

    it 'detects :each for hooks' do
      expect_offense(<<~RUBY)
        before(:each) { true }
        ^^^^^^^^^^^^^ Use `:example` for RSpec hooks.
        after(:each) { true }
        ^^^^^^^^^^^^ Use `:example` for RSpec hooks.
        around(:each) { true }
        ^^^^^^^^^^^^^ Use `:example` for RSpec hooks.
        config.before(:each) { true }
        ^^^^^^^^^^^^^^^^^^^^ Use `:example` for RSpec hooks.
      RUBY

      expect_correction(<<~RUBY)
        before(:example) { true }
        after(:example) { true }
        around(:example) { true }
        config.before(:example) { true }
      RUBY
    end

    it 'detects hooks without default scopes' do
      expect_offense(<<~RUBY)
        before { true }
        ^^^^^^ Use `:example` for RSpec hooks.
        after { true }
        ^^^^^ Use `:example` for RSpec hooks.
        around { true }
        ^^^^^^ Use `:example` for RSpec hooks.
        config.before { true }
               ^^^^^^ Use `:example` for RSpec hooks.
      RUBY

      expect_correction(<<~RUBY)
        before(:example) { true }
        after(:example) { true }
        around(:example) { true }
        config.before(:example) { true }
      RUBY
    end

    include_examples 'an example hook'

    context 'when Ruby 2.7', :ruby27 do
      it 'does not flag :example for hooks' do
        expect_no_offenses(<<~RUBY)
          around(:example) { _1 }
        RUBY
      end

      it 'detects :each for hooks' do
        expect_offense(<<~RUBY)
          around(:each) { _1 }
          ^^^^^^^^^^^^^ Use `:example` for RSpec hooks.
        RUBY

        expect_correction(<<~RUBY)
          around(:example) { _1 }
        RUBY
      end

      it 'detects hooks without default scopes' do
        expect_offense(<<~RUBY)
          around { _1 }
          ^^^^^^ Use `:example` for RSpec hooks.
        RUBY

        expect_correction(<<~RUBY)
          around(:example) { _1 }
        RUBY
      end
    end
  end
end
