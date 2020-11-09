# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Capybara::FeatureMethods do
  it 'flags violations for `background`' do
    expect_offense(<<-RUBY)
      describe 'some feature' do
        background do; end
        ^^^^^^^^^^ Use `before` instead of `background`.
      end
    RUBY

    expect_correction(<<-RUBY)
      describe 'some feature' do
        before do; end
      end
    RUBY
  end

  it 'flags violations for `scenario`' do
    expect_offense(<<-RUBY)
      RSpec.describe 'some feature' do
        scenario 'Foo' do; end
        ^^^^^^^^ Use `it` instead of `scenario`.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe 'some feature' do
        it 'Foo' do; end
      end
    RUBY
  end

  it 'flags violations for `xscenario`' do
    expect_offense(<<-RUBY)
      describe 'Foo' do
        RSpec.xscenario 'Baz' do; end
              ^^^^^^^^^ Use `xit` instead of `xscenario`.
      end
    RUBY

    expect_correction(<<-RUBY)
      describe 'Foo' do
        RSpec.xit 'Baz' do; end
      end
    RUBY
  end

  it 'flags violations for `given`' do
    expect_offense(<<-RUBY)
      RSpec.describe 'Foo' do
        given(:foo) { :foo }
        ^^^^^ Use `let` instead of `given`.
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe 'Foo' do
        let(:foo) { :foo }
      end
    RUBY
  end

  it 'flags violations for `given!`' do
    expect_offense(<<-RUBY)
      describe 'Foo' do
        given!(:foo) { :foo }
        ^^^^^^ Use `let!` instead of `given!`.
      end
    RUBY

    expect_correction(<<-RUBY)
      describe 'Foo' do
        let!(:foo) { :foo }
      end
    RUBY
  end

  it 'flags violations for `feature`' do
    expect_offense(<<-RUBY)
      RSpec.feature 'Foo' do; end
            ^^^^^^^ Use `describe` instead of `feature`.
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe 'Foo' do; end
    RUBY
  end

  it 'ignores variables inside examples' do
    expect_no_offenses(<<-RUBY)
      it 'is valid code' do
        given(feature)
        assign(background)
        run scenario
      end
    RUBY
  end

  it 'ignores feature calls outside spec' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :company do
          feature { "a company" }
          background { Faker::Lorem.sentence }
        end
      end
    RUBY
  end

  it 'allows includes before the spec' do
    expect_offense(<<-RUBY)
      require 'rails_helper'

      RSpec.feature 'Foo' do; end
            ^^^^^^^ Use `describe` instead of `feature`.
    RUBY
  end

  context 'with configured `EnabledMethods`' do
    let(:cop_config) { { 'EnabledMethods' => %w[feature] } }

    it 'ignores usage of the enabled method' do
      expect_no_offenses(<<-RUBY)
        RSpec.feature 'feature is enabled' do; end
      RUBY
    end

    it 'flags other methods' do
      expect_offense(<<-RUBY)
        RSpec.feature 'feature is enabled' do
          given(:foo) { :foo }
          ^^^^^ Use `let` instead of `given`.
        end
      RUBY
    end
  end
end
