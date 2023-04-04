# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IndexedLet do
  let(:cop_config) do
    {
      'MaxRepeats' => 2,
      'LetTypes' => ['let']
    }
  end

  context 'when inside describe' do
    context 'when file contains one indexed let' do
      specify do
        expect_no_offenses(<<~RUBY)
          describe SomeService do
            let(:item_1) { create(:item) }
          end
        RUBY
      end
    end

    context 'when file contains maximum indexed repeats' do
      specify do
        expect_offense(<<~RUBY)
          describe SomeService do
          ^^^^^^^^^^^^^^^^^^^^^^^ This block declares indexed `let` statements: `item_x`. Please give them meaningful names, use create_list or move creation to the `before` block.
            let(:item_1) { create(:item) }
            let(:item_2) { create(:item) }
            let(:item_3) { create(:item) }
          end
        RUBY
      end
    end
  end

  context 'when inside context' do
    context 'when file contains one indexed let' do
      specify do
        expect_no_offenses(<<~RUBY)
          context SomeService do
            let(:item_1) { create(:item) }
          end
        RUBY
      end
    end

    context 'when file contains maximum indexed repeats' do
      specify do
        expect_offense(<<~RUBY)
          context SomeService do
          ^^^^^^^^^^^^^^^^^^^^^^ This block declares indexed `let` statements: `item_x`. Please give them meaningful names, use create_list or move creation to the `before` block.
            let(:item_1) { create(:item) }
            let(:item_2) { create(:item) }
            let(:item_3) { create(:item) }
          end
        RUBY
      end
    end

    context 'when indexed lets are inside nested contexts' do
      specify do
        expect_no_offenses(<<~RUBY)
          describe SomeService do
            let(:item_1) { create(:item) }
            let(:item_2) { create(:item) }

            context "some context" do
              let(:item_3) { create(:item) }
            end
          end
        RUBY
      end
    end

    context 'when names have two numbers' do
      specify do
        expect_offense(<<~RUBY)
          context SomeService do
          ^^^^^^^^^^^^^^^^^^^^^^ This block declares indexed `let` statements: `user_item_x`. Please give them meaningful names, use create_list or move creation to the `before` block.
            let(:user_1_item_1) { create(:item) }
            let(:user_1_item_2) { create(:item) }
            let(:user_2_item_1) { create(:item) }
          end
        RUBY
      end
    end
  end

  describe 'before' do
    context 'when file contains maximum indexed repeats' do
      specify do
        expect_offense(<<~RUBY)
          context SomeService do
            before do
            ^^^^^^^^^ This block declares indexed `let` statements: `item_x`. Please give them meaningful names, use create_list or move creation to the `before` block.
              item_1 = create(:item)
              item_2 = create(:item)
              item_1 = create(:item)
            end
          end
        RUBY
      end
    end
  end
end
