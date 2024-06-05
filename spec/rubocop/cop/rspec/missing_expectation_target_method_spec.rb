# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MissingExpectationTargetMethod do
  it 'registers offenses to other than `to` or `not_to`' do
    expect_offense(<<~RUBY)
      it 'something' do
        something = 1
        expect(something).kind_of? Integer
                          ^^^^^^^^ Use `.to`, `.not_to` or `.to_not` to set an expectation.
      end
    RUBY
  end

  it 'registers offenses to other than `to` or `not_to` ' \
     'when block has one expression' do
    expect_offense(<<~RUBY)
      it 'something' do
        expect(something).eq? 42
                          ^^^ Use `.to`, `.not_to` or `.to_not` to set an expectation.
      end
    RUBY
  end

  it 'registers offenses to other than `to` or `not_to` with `is_expected`' do
    expect_offense(<<~RUBY)
      it 'something' do
        is_expected == 42
                    ^^ Use `.to`, `.not_to` or `.to_not` to set an expectation.
      end
    RUBY
  end

  it 'registers offenses to other than `to` or `not_to` with block' do
    expect_offense(<<~RUBY)
      it 'something' do
        expect{something}.kind_of? StandardError
                          ^^^^^^^^ Use `.to`, `.not_to` or `.to_not` to set an expectation.
      end
    RUBY
  end

  it 'accepts void `expect`' do
    expect_no_offenses(<<~RUBY)
      it 'something' do
        expect(something)
      end
    RUBY
  end

  it 'accepts only `expect`' do
    expect_no_offenses(<<~RUBY)
      expect
    RUBY
  end

  %w[to not_to to_not].each do |method|
    it "accepts `.#{method}`" do
      expect_no_offenses(<<~RUBY)
        it 'something' do
          expect(something).#{method} be_a Integer
        end
      RUBY
    end

    it "accepts `.#{method}` with `is_expected`" do
      expect_no_offenses(<<~RUBY)
        it 'something' do
          is_expected.#{method} eq 42
        end
      RUBY
    end

    it "accepts `.#{method}` with block" do
      expect_no_offenses(<<~RUBY)
        it 'something' do
          expect{something}.#{method} raise_error(StandardError)
        end
      RUBY
    end
  end
end
