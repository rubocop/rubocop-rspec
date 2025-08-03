# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LeakyLocalVariable, :config do
  it 'registers an offense when outside variable is used in `before`' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      before { user.update(admin: true) }
    RUBY
  end

  it 'registers an offense when outside variable is used in `it`' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      it 'updates the user' do
        expect { user.update(admin: true) }.to change(user, :updated_at)
      end
    RUBY
  end

  it 'registers an offense when outside variable is used as ' \
     '`it_behaves_like` argument' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      it_behaves_like 'some example', user
    RUBY
  end

  it 'registers an offense when outside variable is used as part of the ' \
     '`it_behaves_like` argument' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      it_behaves_like 'some example', [user, user2]
    RUBY
  end

  it 'registers an offense when outside variable is used in `let`' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      let(:my_user) { user }
    RUBY
  end

  it 'registers an offense when outside variable is used in `subject`' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      subject { user }
    RUBY
  end

  it 'registers an offense when using outside block argument which is also ' \
     'reassigned outside' do
    expect_offense(<<~RUBY)
      shared_examples 'some examples' do |subject|
        subject = SecureRandom.uuid
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end
    RUBY
  end

  it 'registers an offense when variable is used in interpolation inside an ' \
     'example' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      it 'does something' do
        expect("foo_\#{user.name}").to eq("foo_bar")
      end
    RUBY
  end

  it 'registers an offense when outside variable is used as part of `it` ' \
     'argument and in `it` block' do
    expect_offense(<<~RUBY)
      article = foo ? 'a' : 'the'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      it "updates \#{article} user" do
        user.update(preferred_article: article)
      end
    RUBY
  end

  it 'registers an offense when outside variable is used in `it` and ' \
     'reassigned within `it` after referencing' do
    expect_offense(<<~RUBY)
      user = create(:user)
      ^^^^^^^^^^^^^^^^^^^^ Use `let` instead of a local variable which can leak between examples.

      it 'updates the user' do
        expect { user.update(admin: true) }.to change(user, :updated_at)
        user = create(:user)
      end
    RUBY
  end

  it 'does not register an offense when outside variable is used in `it` and ' \
     'reassigned within `it` before referencing' do
    expect_no_offenses(<<~RUBY)
      user = create(:user)

      it 'updates the user' do
        user = create(:user)
        expect { user.update(admin: true) }.to change(user, :updated_at)
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
      it 'updates the user' do
        user = create(:user)

        expect { user.update(admin: true) }.to change(user, :updated_at)
      end
    RUBY
  end

  it 'does not register an offense for two variables of same name in ' \
     'different scopes' do
    expect_no_offenses(<<~RUBY)
      let(:my_user) do
        user = create(:user)
        user.flag!
        user
      end

      it 'updates the user' do
        user = create(:user)

        expect { user.update(admin: true) }.to change(user, :updated_at)
      end
    RUBY
  end

  it 'does not register an offense when variable is used as `it` argument' do
    expect_no_offenses(<<~RUBY)
      description = "updates the user"

      it description do
        expect { user.update(admin: true) }.to change(user, :updated_at)
      end
    RUBY
  end

  it 'does not register an offense when variable is used as part of `it` ' \
     'argument' do
    expect_no_offenses(<<~RUBY)
      article = foo ? 'a' : 'the'

      it "updates \#{article} user" do
        expect { user.update(admin: true) }.to change(user, :updated_at)
      end
    RUBY
  end

  it 'does not register an offense when variable is used in string ' \
     'interpolation for `it_behaves_like` argument' do
    expect_no_offenses(<<~RUBY)
      article = foo ? 'a' : 'the'

      it_behaves_like 'some example', "\#{article} user"
    RUBY
  end

  it 'does not register an offense when variable is used in symbol ' \
     'interpolation for `it_behaves_like` argument' do
    expect_no_offenses(<<~RUBY)
      article = foo ? 'a' : 'the'

      it_behaves_like 'some example', :"\#{article}_user"
    RUBY
  end

  it 'does not register an offense when variable is used as first ' \
     '`it_behaves_like` argument' do
    expect_no_offenses(<<~RUBY)
      examples = foo ? 'definite article' : 'indefinite article'

      it_behaves_like examples
    RUBY
  end

  it 'does not register an offense when block argument is shadowed by local ' \
     'variable' do
    expect_no_offenses(<<~RUBY)
      %i[user user2].each do |user|
        let(user) do
          user = create(:user)
          user.flag!
          user
        end
      end
    RUBY
  end

  it 'does not register an offense when outside variable is not referenced ' \
     'in an example' do
    expect_no_offenses(<<~RUBY)
      user = create(:user)
      user.flag!

      it 'does something' do
        expect(foo).to eq(bar)
      end
    RUBY
  end
end
