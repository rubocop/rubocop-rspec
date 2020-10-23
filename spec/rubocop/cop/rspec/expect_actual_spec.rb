# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExpectActual do
  it 'flags numeric literal values within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(123).to eq(bar)
                 ^^^ Provide the actual you are testing to `expect(...)`.
          expect(12.3).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`.
          expect(1i).to eq(bar)
                 ^^ Provide the actual you are testing to `expect(...)`.
          expect(1r).to eq(bar)
                 ^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq(123)
          expect(bar).to eq(12.3)
          expect(bar).to eq(1i)
          expect(bar).to eq(1r)
        end
      end
    RUBY
  end

  it 'flags boolean literal values within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(true).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`.
          expect(false).to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq(true)
          expect(bar).to eq(false)
        end
      end
    RUBY
  end

  it 'flags string and symbol literal values within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect("foo").to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`.
          expect(:foo).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq("foo")
          expect(bar).to eq(:foo)
        end
      end
    RUBY
  end

  it 'flags literal nil value within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(nil).to eq(bar)
                 ^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq(nil)
        end
      end
    RUBY
  end

  it 'does not flag dynamic values within expect(...)' do
    expect_no_offenses(<<-'RUBY')
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
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect([123]).to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`.
          expect([[123]]).to eq(bar)
                 ^^^^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq([123])
          expect(bar).to eq([[123]])
        end
      end
    RUBY
  end

  it 'flags hashes containing only literal values within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(foo: 1, bar: 2).to eq(bar)
                 ^^^^^^^^^^^^^^ Provide the actual you are testing to `expect(...)`.
          expect(foo: 1, bar: [{}]).to eq(bar)
                 ^^^^^^^^^^^^^^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq(foo: 1, bar: 2)
          expect(bar).to eq(foo: 1, bar: [{}])
        end
      end
    RUBY
  end

  it 'flags ranges containing only literal values within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(1..2).to eq(bar)
                 ^^^^ Provide the actual you are testing to `expect(...)`.
          expect(1...2).to eq(bar)
                 ^^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq(1..2)
          expect(bar).to eq(1...2)
        end
      end
    RUBY
  end

  it 'flags regexps containing only literal values within expect(...)' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(/foo|bar/).to eq(bar)
                 ^^^^^^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eq(/foo|bar/)
        end
      end
    RUBY
  end

  it 'does not flag complex values with dynamic parts within expect(...)' do
    expect_no_offenses(<<-'RUBY')
      describe Foo do
        it 'uses expect incorrectly' do
          expect.to eq(bar)
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

  it 'ignores `be` with no argument' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'uses expect legitimately' do
          expect(1).to be
        end
      end
    RUBY
  end

  it 'flags `be` with an argument' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(true).to be(a)
                 ^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(a).to be(true)
        end
      end
    RUBY
  end

  it 'flags `be ==`' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(1).to be == a
                 ^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(a).to be == 1
        end
      end
    RUBY
  end

  it 'flags with `eql` matcher' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(1).to eql(bar)
                 ^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to eql(1)
        end
      end
    RUBY
  end

  it 'flags with `equal` matcher' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(1).to equal(bar)
                 ^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect(bar).to equal(1)
        end
      end
    RUBY
  end

  it 'flags but does not autocorrect violations for other matchers' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses expect incorrectly' do
          expect([1,2,3]).to include(a)
                 ^^^^^^^ Provide the actual you are testing to `expect(...)`.
        end
      end
    RUBY

    expect_no_corrections
  end

  context 'when inspecting rspec-rails routing specs' do
    let(:cop_config) { {} }

    it 'ignores rspec-rails routing specs' do
      expect_no_offenses(
        'expect(get: "/foo").to be_routeable',
        'spec/routing/foo_spec.rb'
      )
    end
  end
end
