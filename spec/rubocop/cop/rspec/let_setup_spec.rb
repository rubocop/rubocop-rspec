# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LetSetup do
  it 'complains when let! is used and not referenced' do
    expect_offense(<<~RUBY)
      describe Foo do
        let!(:foo) { bar }
        ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

        it 'does not use foo' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'ignores let! when used in `before`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let!(:foo) { bar }

        before do
          foo
        end

        it 'does not use foo' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'ignores let! when used in example' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let!(:foo) { bar }

        it 'uses foo' do
          foo
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'complains when let! is used and not referenced within nested group' do
    expect_offense(<<~RUBY)
      describe Foo do
        context 'when something special happens' do
          let!(:foo) { bar }
          ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'does not use foo' do
            expect(baz).to eq(qux)
          end
        end

        it 'references some other foo' do
          foo
        end
      end
    RUBY
  end

  it 'complains when let! is used and not referenced in shared example group' do
    expect_offense(<<~RUBY)
      shared_context 'foo' do
        let!(:bar) { baz }
        ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

        it 'does not use bar' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'complains when let! used in shared example including' do
    expect_offense(<<~RUBY)
      describe Foo do
        it_behaves_like 'bar' do
          let!(:baz) { foobar }
          ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
          let(:a) { b }
        end
      end
    RUBY
  end

  it 'complains when there is only one nested node into example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        let!(:bar) { baz }
        ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
      end
    RUBY
  end

  it 'flags unused helpers defined as strings' do
    expect_offense(<<~RUBY)
      describe Foo do
        let!('bar') { baz }
        ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
      end
    RUBY
  end

  it 'ignores used helpers defined as strings' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let!('bar') { baz }
        it { expect(bar).to be_near }
      end
    RUBY
  end

  it 'flags blockpass' do
    expect_offense(<<~RUBY)
      shared_context Foo do |&block|
        let!(:bar, &block)
        ^^^^^^^^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
      end
    RUBY
  end

  it 'complains when there is a custom nesting level' do
    expect_offense(<<~RUBY)
      describe Foo do
        [].each do |i|
          let!(:bar) { i }
          ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'does not use bar' do
            expect(baz).to eq(qux)
          end
        end
      end
    RUBY
  end

  it 'ignores let! that overrides outer scope let!' do
    expect_no_offenses(<<~RUBY)
      describe User, type: :model do
        let!(:user) { create(:user) }

        it 'is valid' do
          expect(user).to be_valid
        end

        context 'with no direct usage' do
          let!(:user) { create(:user, :special) }

          it 'creates something' do
            expect(SomeModel.count).to eq(2)
          end
        end
      end
    RUBY
  end

  it 'ignores let! overriding outer scope across multiple nesting levels' do
    expect_no_offenses(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        context 'level 1' do
          context 'level 2' do
            let!(:user) { create(:user, :admin) }

            it 'creates admin user' do
              expect(User.count).to eq(2)
            end
          end
        end
      end
    RUBY
  end

  it 'still flags unused let! when outer scope has different name' do
    expect_offense(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        context 'different variable' do
          let!(:admin) { create(:user, :admin) }
          ^^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'creates admin user' do
            expect(User.count).to eq(2)
          end
        end
      end
    RUBY
  end

  it 'allows let! override when outer let! is used elsewhere' do
    expect_no_offenses(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        context 'special case' do
          let!(:user) { create(:user, :special) }

          it 'setup only' do
            expect(User.count).to eq(2)
          end
        end
      end
    RUBY
  end

  it 'does not consider non-RSpec blocks as outer scope' do
    expect_offense(<<~RUBY)
      describe User do
        [1, 2, 3].each do |i|
          let!(:user) { create(:user, id: i) }
          ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'creates user' do
            expect(User.count).to eq(3)
          end
        end
      end
    RUBY
  end

  it 'correctly identifies override through mixed block types' do
    expect_no_offenses(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        [true, false].each do |flag|
          context "when flag is \#{flag}" do
            let!(:user) { create(:user, flag: flag) }

            it 'setup only' do
              expect(User.count).to be > 0
            end
          end
        end
      end
    RUBY
  end
end
