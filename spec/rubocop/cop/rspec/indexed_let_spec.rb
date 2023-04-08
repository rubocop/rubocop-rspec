# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IndexedLet do
  let(:max_repeats) { 1 }
  let(:cop_config) { { 'MaxRepeats' => max_repeats } }

  specify do
    expect_offense(<<~RUBY)
      describe SomeService do
        let(:item_1) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
        let(:item_2) { create(:item) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
      end
    RUBY
  end

  context 'with strings' do
    specify do
      expect_offense(<<~RUBY)
        describe SomeService do
          let("item_1") { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
          let("item_2") { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
        end
      RUBY
    end
  end

  context 'without underscores' do
    specify do
      expect_offense(<<~RUBY)
        describe SomeService do
          let(:item1) { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
          let(:item2) { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
        end
      RUBY
    end
  end

  context 'with blockpass' do
    specify do
      expect_offense(<<~RUBY)
        describe SomeService do
          let(:item_1, &block)
          ^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
          let(:item_2, &block)
          ^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
        end
      RUBY
    end
  end

  context 'when indexed lets are inside nested contexts' do
    specify do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }

          context "some context" do
            let(:item_2) { create(:item) }
          end
        end
      RUBY
    end
  end

  context 'when names have two numbers' do
    specify do
      expect_offense(<<~RUBY)
        context SomeService do
          let(:user_1_item_1) { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
          let(:user_1_item_2) { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
          let(:user_2_item_1) { create(:item) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This `let` statement uses index in its name. Please give it a meaningful names, use create_list or move creation to the `before` block.
        end
      RUBY
    end
  end

  context 'when maximum is not reached' do
    specify do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }
        end
      RUBY
    end
  end

  context 'when MaxRepeats is 2' do
    let(:max_repeats) { 2 }

    specify do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          let(:item_1) { create(:item) }
        end
      RUBY
    end
  end
end
