# frozen_string_literal: true

describe RuboCop::Cop::RSpec::ExpectActual do
  subject(:cop) { described_class.new }

  it 'flags numeric literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(123).to eq(bar)
                 ^^^ Provide the actual you are testing to `expect(...)`
          expect(12.3).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`
          expect(1i).to eq(bar)
                 ^^ Provide the actual you are testing to `expect(...)`
          expect(1r).to eq(bar)
                 ^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'flags boolean literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(true).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`
          expect(false).to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'flags string and symbol literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect("foo").to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`
          expect(:foo).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'flags literal nil value within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(nil).to eq(bar)
                 ^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'does not flag dynamic values within expect(...)' do
    expect_no_violations(<<-'RUBY')
      describe Foo do
        it 'uses expect correctly' do
          expect(foo).to eq(bar)
          expect("foo#{baz}").to eq(bar)
          expect(:"foo#{baz}").to  eq(bar)
        end
      end
    RUBY
  end

  it 'flags arrays containing only literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect([123]).to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`
          expect([[123]]).to eq(bar)
                 ^^^^^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'flags hashes containing only literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(foo: 1, bar: 2).to eq(bar)
                 ^^^^^^^^^^^^^^ Provide the actual you are testing to `expect(...)`
          expect(foo: 1, bar: [{}]).to eq(bar)
                 ^^^^^^^^^^^^^^^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'flags ranges containing only literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(1..2).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`
          expect(1...2).to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'flags regexps containing only literal values within expect(...)' do
    expect_violation(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(/foo|bar/).to eq(bar)
                 ^^^^^^^^^ Provide the actual you are testing to `expect(...)`
        end
      end
    RUBY
  end

  it 'does not flag complex values with dynamic parts within expect(...)' do
    expect_no_violations(<<-'RUBY')
      describe Foo do
        it 'uses expect incorrectly' do
          expect([foo]).to eq(bar)
          expect([[foo]]).to eq(bar)
          expect(foo: 1, bar: foo).to eq(bar)
          expect(1..foo).to eq(bar)
          expect(1...foo).to eq(bar)
          expect(/foo|#{bar}/).to eq(bar)
        end
      end
    RUBY
  end
end
