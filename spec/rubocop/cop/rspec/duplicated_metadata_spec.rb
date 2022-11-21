# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DuplicatedMetadata do
  context 'when metadata is not used' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        describe 'Something' do
        end
      RUBY
    end
  end

  context 'when metadata is not duplicated' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        describe 'Something', :a, :b do
        end
      RUBY
    end
  end

  context 'when metadata is duplicated on example group' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'Something', :a, :a do
                                  ^^ Avoid duplicated metadata.
        end
      RUBY

      expect_correction(<<~RUBY)
        describe 'Something', :a do
        end
      RUBY
    end
  end

  context 'when metadata is duplicated in different order' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'Something', :a, :b, :a do
                                      ^^ Avoid duplicated metadata.
        end
      RUBY

      expect_correction(<<~RUBY)
        describe 'Something', :a, :b do
        end
      RUBY
    end
  end

  context 'when metadata is duplicated on example' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        it 'does something', :a, :a do
                                 ^^ Avoid duplicated metadata.
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'does something', :a do
        end
      RUBY
    end
  end

  context 'when metadata is duplicated on shared examples' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        shared_examples 'something', :a, :a do
                                         ^^ Avoid duplicated metadata.
        end
      RUBY

      expect_correction(<<~RUBY)
        shared_examples 'something', :a do
        end
      RUBY
    end
  end

  context 'when metadata is duplicated on configuration hook' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        RSpec.configure do |configuration|
          configuration.before(:each, :a, :a) do
                                          ^^ Avoid duplicated metadata.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.configure do |configuration|
          configuration.before(:each, :a) do
          end
        end
      RUBY
    end
  end
end
