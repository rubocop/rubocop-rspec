# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyExampleGroup, :config do
  it 'flags an empty example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        context 'when bar' do
        ^^^^^^^^^^^^^^^^^^ Empty example group detected.

          let(:foo) { bar }
        end

        describe '#thingy?' do
          specify do
            expect(whatever.thingy?).to be(true)
          end
        end

        it { should be_true }
      end
    RUBY
  end

  it 'flags an empty top level describe' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^ Empty example group detected.
      end
    RUBY
  end

  it 'flags example group with examples defined in hooks' do
    expect_offense(<<~RUBY)
      context 'hook with implicit scope' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
        before do
          it 'yields a block when given' do
            value = nil

            helper.feature('whatevs') { value = 5 }

            expect(value).to be 5
          end
        end
      end
    RUBY
  end

  it 'ignores example group with examples defined in iterator' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop monthly' do
        [1, 2, 3].each do |page|
          it { expect(newspaper(page)).to have_ads }
        end
      end
    RUBY
  end

  it 'ignores example group with examples defined in an iterator' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop weekly' do
        some_method
        [1, 2, 3].each do |page|
          it { expect(newspaper(page)).to have_ads }
        end
        more_surroundings
      end
    RUBY
  end

  it 'flags example group with no examples defined in an iterator' do
    expect_offense(<<~RUBY)
      describe 'RuboCop Sunday' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
        some_method
        [1, 2, 3].each do |page|
          no_examples_here
          and_no_ads_either
        end
        more_surroundings
      end
    RUBY
  end

  it 'ignores example group with examples defined in a nested iterator' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop daily' do
        some_method
        [1, 2, 3].each do |page|
          some_method
          [1, 2, 3].each do |paragraph|
            it { expect(newspaper(page, paragraph)).to have_ads }
          end
          more_surroundings
        end
        more_surroundings
      end
    RUBY
  end

  it 'ignores examples groups with includes' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        context "when something is true" do
          include_examples "some expectations"
        end

        context "when something else is true" do
          include_context "some expectations"
        end

        context "when a third thing is true" do
          it_behaves_like "some thingy"
        end
      end
    RUBY
  end

  it 'ignores methods matching example group names' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'yields a block when given' do
          value = nil

          helper.feature('whatevs') { value = 5 }

          expect(value).to be 5
        end
      end
    RUBY
  end

  it 'flags custom include methods by default' do
    expect_offense(<<~RUBY)
      describe Foo do
        context "when I do something clever" do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
          it_has_special_behavior
        end
      end
    RUBY
  end

  context 'when a custom include method is specified' do
    let(:cop_config) do
      { 'CustomIncludeMethods' => %w[it_has_special_behavior] }
    end

    it 'ignores an empty example group with a custom include' do
      expect_no_offenses(<<~RUBY)
        describe Foo do
          context "when I do something clever" do
            it_has_special_behavior
          end
        end
      RUBY
    end
  end
end
