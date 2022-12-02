# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::TravelAround do
  context 'with `freeze_time` in `before`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        before { freeze_time }
      RUBY
    end
  end

  context 'with `freeze_time` in `around(:all)`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        around(:all) do |example|
          freeze_time do
            example.run
          end
        end
      RUBY
    end
  end

  context 'with `freeze_time` in `around(:suite)`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        around(:suite) do |example|
          freeze_time do
            example.run
          end
        end
      RUBY
    end
  end

  context 'with another step in `freeze_time`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        around do |example|
          freeze_time do
            do_some_preparation
            example.run
          end
        end
      RUBY
    end
  end

  context 'with `freeze_time` in `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around do |example|
          freeze_time do
          ^^^^^^^^^^^^^^ Prefer to travel in `before` rather than `around`.
            example.run
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        before { freeze_time }

        around do |example|
          example.run
        end
      RUBY
    end
  end

  context 'with `freeze_time` in `around(:each)`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around(:each) do |example|
          freeze_time do
          ^^^^^^^^^^^^^^ Prefer to travel in `before` rather than `around`.
            example.run
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        before { freeze_time }

        around(:each) do |example|
          example.run
        end
      RUBY
    end
  end

  context 'with `freeze_time` and another node in `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around do |example|
          foo

          freeze_time do
          ^^^^^^^^^^^^^^ Prefer to travel in `before` rather than `around`.
            example.run
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        before { freeze_time }

        around do |example|
          foo

          example.run
        end
      RUBY
    end
  end

  context 'with `travel` in `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around do |example|
          travel(duration) do
          ^^^^^^^^^^^^^^^^^^^ Prefer to travel in `before` rather than `around`.
            example.run
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        before { travel(duration) }

        around do |example|
          example.run
        end
      RUBY
    end
  end

  context 'with `travel_to` in `around`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        around do |example|
          travel_to(time) do
          ^^^^^^^^^^^^^^^^^^ Prefer to travel in `before` rather than `around`.
            example.run
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        before { travel_to(time) }

        around do |example|
          example.run
        end
      RUBY
    end
  end
end
