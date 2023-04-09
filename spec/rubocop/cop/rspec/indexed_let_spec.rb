# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IndexedLet do
  let(:max_repeats) { 1 }
  let(:cop_config) { { 'MaxRepeats' => max_repeats } }

  it 'flags repeated symbol names' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let(:item_2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
      end
    RUBY
  end

  it 'flags repeated string names' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let("item_1") { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let("item_2") { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
      end
    RUBY
  end

  it 'flags repeated names without underscores' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let(:item2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
      end
    RUBY
  end

  it 'flags repeated names with blockpasses' do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item_1, &block)
        ^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let(:item_2, &block)
        ^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
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
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let(:user_1_item_2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let(:user_2_item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
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
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
        let("item_2") { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful name, use create_list or move creation to a `before` block.
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

  context 'when MaxRepeats is 2' do
    let(:max_repeats) { 2 }

    it 'not flags one indexed let because maximum not reached' do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }
          let(:item_2) { create(:item) }
        end
      RUBY
    end
  end
end
