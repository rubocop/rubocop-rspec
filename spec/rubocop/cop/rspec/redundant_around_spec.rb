# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RedundantAround do
  context 'with another node in `around`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        around do |example|
          example.run

          foo
        end
      RUBY
    end
  end

  context 'with block-surrounded `run` in `around`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        around do |example|
          foo { example.run }
        end
      RUBY
    end
  end

  context 'with redundant `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around do |example|
        ^^^^^^^^^^^^^^^^^^^ Remove redundant `around` hook.
          example.run
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end
  end

  context 'with redundant block-pass `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around(&:run)
        ^^^^^^^^^^^^^ Remove redundant `around` hook.
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end
  end

  context 'with redundant numblock `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around do
        ^^^^^^^^^ Remove redundant `around` hook.
          _1.run
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end
  end

  context 'with redundant `config.around' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        config.around do |example|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove redundant `around` hook.
          example.run
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end
  end

  context 'with redundant `config.around(:each)' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        config.around(:each) do |example|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove redundant `around` hook.
          example.run
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end
  end
end
