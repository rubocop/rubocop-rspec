# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExpectChange do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'with EnforcedStyle `method_call`' do
    let(:enforced_style) { 'method_call' }

    it 'flags blocks that contain simple message sending' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change { User.count }.by(1)
                            ^^^^^^^^^^^^^^^^^^^^^ Prefer `change(User, :count)`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change(User, :count).by(1)
        end
      RUBY
    end

    it 'ignores blocks when the method is called with arguments' do
      expect_no_offenses(<<-RUBY)
        it do
          expect { run }.to change { User.sum(:points) }
        end
      RUBY
    end

    it 'ignores when not an expectation' do
      expect_no_offenses(<<-RUBY)
        it do
          Record.change { User.count }
        end
      RUBY
    end

    it 'flags implicit block expectation syntax' do
      expect_offense(<<-RUBY)
        it do
          expect(run).to change { User.count }.by(1)
                         ^^^^^^^^^^^^^^^^^^^^^ Prefer `change(User, :count)`.
        end
      RUBY
    end

    it 'ignores the usage that adheres to the enforced style' do
      expect_no_offenses(<<-RUBY)
        it do
          expect { run }.to change(User, :count).by(1)
        end
      RUBY
    end

    it 'flags when the received is a namespaced constant' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change { User::Token::Auth.count }.by(1)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change(User::Token::Auth, :count)`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change(User::Token::Auth, :count).by(1)
        end
      RUBY
    end

    it 'flags when the receiver is a top-level constant' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change { ::User.count }.by(1)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change(::User, :count)`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change(::User, :count).by(1)
        end
      RUBY
    end

    it 'flags chained method calls' do
      expect_offense(<<-RUBY)
        it do
          expect { file.upload! }.to change { user.uploads.count }.by(1)
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change(user.uploads, :count)`.
        end
      RUBY
    end
  end

  context 'with EnforcedStyle `block`' do
    let(:enforced_style) { 'block' }

    it 'flags change matcher without block' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(User, :count).by(1)
                            ^^^^^^^^^^^^^^^^^^^^ Prefer `change { User.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { User.count }.by(1)
        end
      RUBY
    end

    it 'flags change matcher when receiver is a namespaced constant' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(User::Token::Auth, :count).by(1)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { User::Token::Auth.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { User::Token::Auth.count }.by(1)
        end
      RUBY
    end

    it 'flags change matcher when receiver is a variable' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(user, :count)
                            ^^^^^^^^^^^^^^^^^^^^ Prefer `change { user.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { user.count }
        end
      RUBY
    end

    it 'flags change matcher when message is a string' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(user, 'status')
                            ^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { user.status }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { user.status }
        end
      RUBY
    end

    it 'registers an offense for change matcher with chained method call' do
      expect_offense(<<-RUBY)
        it do
          expect { paint_users! }.to change(users.green, :count).by(1)
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { users.green.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { paint_users! }.to change { users.green.count }.by(1)
        end
      RUBY
    end

    it 'flags change matcher when receiver is a top-level constant' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(::User, :count)
                            ^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { ::User.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { ::User.count }
        end
      RUBY
    end

    it 'registers an offense for change matcher with an instance variable' do
      expect_offense(<<-RUBY)
        it do
          expect { paint_users! }.to change(@food, :taste).to(:sour)
                                     ^^^^^^^^^^^^^^^^^^^^^ Prefer `change { @food.taste }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { paint_users! }.to change { @food.taste }.to(:sour)
        end
      RUBY
    end

    it 'registers an offense for change matcher with a global variable' do
      expect_offense(<<-RUBY)
        it do
          expect { paint_users! }.to change($token, :value).to(nil)
                                     ^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { $token.value }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { paint_users! }.to change { $token.value }.to(nil)
        end
      RUBY
    end

    it 'ignores methods called change' do
      expect_no_offenses(<<-RUBY)
        it do
          record.change(user, :count)
        end
      RUBY
    end

    it 'flags implicit block expectation syntax' do
      expect_offense(<<-RUBY)
        it do
          expect(run).to change(User, :count).by(1)
                         ^^^^^^^^^^^^^^^^^^^^ Prefer `change { User.count }`.
        end
      RUBY
    end
  end
end
