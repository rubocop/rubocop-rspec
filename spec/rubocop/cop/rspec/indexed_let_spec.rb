# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IndexedLet do
  let(:max) { 1 }
  let(:allowed_patterns) { [] }
  let(:allowed_identifiers) { [] }
  let(:cop_config) do
    {
      'Max' => max,
      'AllowedIdentifiers' => allowed_identifiers,
      'AllowedPatterns' => allowed_patterns
    }
  end

  it 'flags repeated symbol names' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let(:item_2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
      end
    RUBY
  end

  it 'flags repeated string names' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let("item_1") { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let("item_2") { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
      end
    RUBY
  end

  it 'flags repeated names without underscores' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let(:item2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
      end
    RUBY
  end

  it 'flags repeated names with blockpasses' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item_1, &block)
        ^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let(:item_2, &block)
        ^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
      end
    RUBY
  end

  it 'not flags indexed lets inside nested contexts' do
    expect_no_offenses(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }

        context "some context" do
          let(:item_2) { create(:item) }
        end
      end
    RUBY
  end

  it 'flags names with two numbers' do
    expect_offense(<<~RUBY)
      context SomeService do
        let(:user_1_item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let(:user_1_item_2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let(:user_2_item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
      end
    RUBY
  end

  it 'ignores names with an index-like and a suffix' do
    expect_no_offenses(<<~RUBY)
      context SomeService do
        let(:user_7_day_average) { 700 }
        let(:user_30_day_average) { 3000 }
      end
    RUBY
  end

  it 'not flags which have different prefixes' do
    expect_no_offenses(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }
        let(:foo_item_1) { create(:item) }
      end
    RUBY
  end

  it 'not flags item without index' do
    expect_no_offenses(<<~RUBY)
      describe SomeService do
        let(:item) { create(:item) }
        let(:item_1) { create(:item) }
      end
    RUBY
  end

  it 'flags mixed symbols and strings' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
        let("item_2") { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name.
      end
    RUBY
  end

  it 'not flags one indexed let because maximum not reached' do
    expect_no_offenses(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }
      end
    RUBY
  end

  context 'when Max is 2' do
    let(:max) { 2 }

    it 'not flags one indexed let because maximum not reached' do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }
          let(:item_2) { create(:item) }
        end
      RUBY
    end
  end

  context 'when AllowedIdentifiers is set' do
    let(:allowed_identifiers) { %w[item_1 item_2] }

    it 'not flags allowed indexed let' do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }
          let(:item_2) { create(:item) }
        end
      RUBY
    end
  end

  context 'when AllowedPatterns is set' do
    let(:allowed_patterns) { %w[item] }

    it 'not flags allowed indexed let' do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }
          let(:item_2) { create(:item) }
        end
      RUBY
    end
  end
end
