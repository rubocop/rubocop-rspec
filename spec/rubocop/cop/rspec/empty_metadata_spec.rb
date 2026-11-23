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

  context 'with a block-pass' do
    it 'registers offense for empty metadata hash' do
      expect_offense(<<~RUBY)
        it('Something', {}, &blk)
                        ^^ Avoid empty metadata hash.
        describe 'Something', {}, &blk
                              ^^ Avoid empty metadata hash.
      RUBY

      expect_correction(<<~RUBY)
        it('Something', &blk)
        describe 'Something', &blk
      RUBY
    end

    it 'registers no offense without metadata' do
      expect_no_offenses(<<~RUBY)
        describe 'Something', &blk
        it(&blk)
      RUBY
    end

    it 'registers no offense for non-empty metadata hash' do
      expect_no_offenses(<<~RUBY)
        describe 'Something', { a: b }, &blk
      RUBY
    end

    it 'registers no offense for splat kwargs metadata' do
      expect_no_offenses(<<~RUBY)
        describe 'Something', **{ a: b }, &blk
      RUBY
    end
  end

end
