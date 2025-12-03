# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeakyLocalVariable, :config do
  it 'registers an offense when outside variable is used in `before`' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        before { user.update(admin: true) }
      end
    RUBY
  end

  it 'registers an offense when outside variable is used in `it`' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it 'updates the user' do
          expect { user.update(admin: true) }.to change(user, :updated_at)
        end
      end
    RUBY
  end

  it 'registers an offense when outside variable is used as ' \
     '`it_behaves_like` argument' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it_behaves_like 'some example', user
      end
    RUBY
  end

  it 'registers an offense when outside variable is used as part of the ' \
     '`it_behaves_like` argument' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it_behaves_like 'some example', [user, user2]
      end
    RUBY
  end

  it 'registers an offense when outside variable is used in `let`' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        let(:my_user) { user }
      end
    RUBY
  end

  it 'registers an offense when outside variable is used in `subject`' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        subject { user }
      end
    RUBY
  end

  it 'registers an offense when using outside block argument which is also ' \
     'reassigned outside' do
    expect_offense(<<~RUBY)
      shared_examples 'some examples' do |subject|
        subject = SecureRandom.uuid
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end
    RUBY
  end

  it 'registers an offense when variable is used in interpolation inside an ' \
     'example' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it 'does something' do
          expect("foo_\#{user.name}").to eq("foo_bar")
        end
      end
    RUBY
  end

  it 'registers an offense when outside variable is used as part of `it` ' \
     'argument and in `it` block' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        article = foo ? 'a' : 'the'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it "updates \#{article} user" do
          user.update(preferred_article: article)
        end
      end
    RUBY
  end

  it 'registers an offense when outside variable is used in `it` and ' \
     'reassigned within `it` after referencing' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it 'updates the user' do
          expect { user.update(admin: true) }.to change(user, :updated_at)
          user = create(:user)
        end
      end
    RUBY
  end

  it 'registers an offense when variable assigned outside of ' \
     'described block is used in `before`' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

      describe SomeClass do
        before { user.update(admin: true) }
      end
    RUBY
  end

  it 'does not register an offense when outside variable is used in `it` and ' \
     'reassigned within `it` before referencing' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        user = create(:user)

        it 'updates the user' do
          user = create(:user)
          expect { user.update(admin: true) }.to change(user, :updated_at)
        end
      end
    RUBY
  end

  it 'does not register an offense when using outside block argument which ' \
     'is reassigned inside' do
    expect_no_offenses(<<~RUBY)
      shared_examples 'some examples' do |subject|
        it 'renders the subject' do
          subject = 'hello'
          expect(mail.subject).to eq(subject)
        end
      end
    RUBY
  end

  it 'does not register an offense when using outside block argument' do
    expect_no_offenses(<<~RUBY)
      shared_examples 'some examples' do |subject|
        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end
    RUBY
  end

  it 'does not register an offense when using outside block keyword argument' do
    expect_no_offenses(<<~RUBY)
      shared_examples 'some examples' do |subject:|
        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end
    RUBY
  end

  it 'does not register an offense when variable is assigned in the example ' \
     'scope' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        it 'updates the user' do
          user = create(:user)

          expect { user.update(admin: true) }.to change(user, :updated_at)
        end
      end
    RUBY
  end

  it 'does not register an offense for two variables of same name in ' \
     'different scopes' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        let(:my_user) do
          user = create(:user)
          user.flag!
          user
        end

        it 'updates the user' do
          user = create(:user)

          expect { user.update(admin: true) }.to change(user, :updated_at)
        end
      end
    RUBY
  end

  it 'does not register an offense when variable is used as `it` argument' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        description = "updates the user"

        it description do
          expect { user.update(admin: true) }.to change(user, :updated_at)
        end
      end
    RUBY
  end

  it 'does not register an offense when variable is used as part of `it` ' \
     'argument' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        article = foo ? 'a' : 'the'

        it "updates \#{article} user" do
          expect { user.update(admin: true) }.to change(user, :updated_at)
        end
      end
    RUBY
  end

  it 'does not register an offense when variable is used in string ' \
     'interpolation for `it_behaves_like` argument' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        article = foo ? 'a' : 'the'

        it_behaves_like 'some example', "\#{article} user"
      end
    RUBY
  end

  it 'does not register an offense when variable is used in symbol ' \
     'interpolation for `it_behaves_like` argument' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        article = foo ? 'a' : 'the'

        it_behaves_like 'some example', :"\#{article}_user"
      end
    RUBY
  end

  it 'does not register an offense when variable is used as first ' \
     '`it_behaves_like` argument' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        examples = foo ? 'definite article' : 'indefinite article'

        it_behaves_like examples
      end
    RUBY
  end

  it 'does not register an offense when block argument is shadowed by local ' \
     'variable' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        %i[user user2].each do |user|
          let(user) do
            user = create(:user)
            user.flag!
            user
          end
        end
      end
    RUBY
  end

  it 'does not register an offense when outside variable is not referenced ' \
     'in an example' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        user = create(:user)
        user.flag!

        it 'does something' do
          expect(foo).to eq(bar)
        end
      end
    RUBY
  end

  it 'does not register an offense when outside of a describe block' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define :foo do
        bar = 123

        after(:create) do |foo|
          foo.update(bar: bar)
        end
      end
    RUBY
  end

  it 'does not register an offense when variable is used only in skip ' \
     'metadata' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        skip_message = 'not yet implemented'

        it 'does something', skip: skip_message do
          expect(1 + 2).to eq(3)
        end
      end
    RUBY
  end

  it 'does not register an offense when variable is used only in pending ' \
     'metadata' do
    expect_no_offenses(<<~RUBY)
      describe SomeClass do
        pending_message = 'work in progress'

        it 'does something', pending: pending_message do
          expect(1 + 2).to eq(3)
        end
      end
    RUBY
  end

  it 'registers an offense when variable is used in skip metadata and in ' \
     'block body' do
    expect_offense(<<~RUBY)
      describe SomeClass do
        skip_message = 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use local variables defined outside of examples inside of them.

        it 'does something', skip: skip_message do
          puts skip_message
        end
      end
    RUBY
  end
end
