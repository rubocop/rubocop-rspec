# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::VariableDefinition do
  context 'when EnforcedStyle is `symbols`' do
    let(:cop_config) { { 'EnforcedStyle' => 'symbols' } }

    it 'registers an offense for string name' do
      expect_offense(<<~RUBY)
        let('user_name') { 'Adam' }
            ^^^^^^^^^^^ Use symbols for variable names.
      RUBY
    end

    it 'does not register offense for interpolated string' do
      expect_no_offenses(<<~'RUBY')
        let("user-#{id}") { 'Adam' }
      RUBY
    end

    it 'does not register offense for multiline string' do
      expect_no_offenses(<<~'RUBY')
        let("user" \
            "-foo") { 'Adam' }
      RUBY
    end

    it 'does not register offense for symbol names' do
      expect_no_offenses(<<~RUBY)
        let(:user_name) { 'Adam' }
      RUBY
    end
  end

  context 'when EnforcedStyle is `strings`' do
    let(:cop_config) { { 'EnforcedStyle' => 'strings' } }

    it 'registers an offense for symbol name' do
      expect_offense(<<~RUBY)
        let(:user_name) { 'Adam' }
            ^^^^^^^^^^ Use strings for variable names.
      RUBY
    end

    it 'registers an offense for interpolated symbol' do
      expect_offense(<<~'RUBY')
        let(:"user-#{id}") { 'Adam' }
            ^^^^^^^^^^^^^ Use strings for variable names.
      RUBY
    end

    it 'does not register offense for string names' do
      expect_no_offenses(<<~RUBY)
        let('user_name') { 'Adam' }
      RUBY
    end
  end
end
