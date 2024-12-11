# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyMetadata do
  context 'without metadata' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        describe 'Something' do
        end
      RUBY
    end
  end

  context 'with non-empty metadata hash' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        describe 'Something', { a: b } do
        end
      RUBY
    end
  end

  context 'with empty metadata hash' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        describe 'Something', {} do
                              ^^ Avoid empty metadata hash.
        end
      RUBY

      expect_correction(<<~RUBY)
        describe 'Something' do
        end
      RUBY
    end
  end

  it 'registers no offense for splat kwargs metadata' do
    expect_no_offenses(<<~RUBY)
      describe 'Something', **{ a: b } do
      end
    RUBY
  end
end
