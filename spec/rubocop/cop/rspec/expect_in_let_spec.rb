# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExpectInLet do
  it 'adds an offense for `expect` in let' do
    expect_offense(<<~RUBY)
      let(:foo) do
        expect(something).to eq 'foo'
        ^^^^^^ Do not use `expect` in let
      end
    RUBY
  end


  it 'adds an offense for `is_expected` in let' do
    expect_offense(<<~RUBY)
      let(:foo) do
        is_expected.to eq 'foo'
        ^^^^^^^^^^^ Do not use `is_expected` in let
      end
    RUBY
  end

  it 'adds an offense for `expect_any_instance_of` in let' do
    expect_offense(<<~RUBY)
      let(:foo) do
        expect_any_instance_of(Something).to receive :foo
        ^^^^^^^^^^^^^^^^^^^^^^ Do not use `expect_any_instance_of` in let
      end
    RUBY
  end

  it 'adds offenses for multiple expectations in let' do
    expect_offense(<<~RUBY)
      let(:foo) do
        expect(something).to eq 'foo'
        ^^^^^^ Do not use `expect` in let
        is_expected.to eq 'foo'
        ^^^^^^^^^^^ Do not use `is_expected` in let
      end
    RUBY
  end

  it 'accepts an empty let' do
    expect_no_offenses(<<~RUBY)
      let(:foo) {}
    RUBY
  end

  it 'accepts `expect` in `it`' do
    expect_no_offenses(<<~RUBY)
      it do
        expect(something).to eq 'foo'
        is_expected.to eq 'foo'
        expect_any_instance_of(Something).to receive :foo
      end
    RUBY
  end
end
