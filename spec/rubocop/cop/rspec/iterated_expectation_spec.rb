# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IteratedExpectation do
  it 'flags `each` with an expectation' do
    expect_offense(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| expect(user).to be_valid }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'validates users' do
        expect([user1, user2, user3]).to all(be_valid)
      end
    RUBY
  end

  it 'flags `each` when expectation calls method with arguments' do
    expect_offense(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| expect(user).to be_a(User) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'validates users' do
        expect([user1, user2, user3]).to all(be_a(User))
      end
    RUBY
  end

  it 'flags `each` when the expectation specifies an error message, but ' \
     'does not correct' do
    expect_offense(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| expect(user).to be_a(User), "user is not a User" }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
      end
    RUBY

    expect_no_corrections
  end

  it 'flags `each` when matcher uses block argument, but does not correct' do
    expect_offense(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| expect(user).to receive(:flag).and_return(user.flag) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
      end
    RUBY

    expect_no_corrections
  end

  it 'ignores `each` without expectation' do
    expect_no_offenses(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| allow(user).to receive(:method) }
      end
    RUBY
  end

  it 'ignores `each` with unused variable' do
    expect_no_offenses(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |_user| do_something }
      end
    RUBY
  end

  it 'flags `each` with multiple expectations' do
    expect_offense(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each do |user|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
          expect(user).to receive(:method)
          expect(user).to receive(:other_method)
        end
      end
    RUBY

    expect_no_corrections
  end

  it 'ignore `each` when the body does not contain only expectations' do
    expect_no_offenses(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each do |user|
          allow(Something).to receive(:method).and_return(user)
          expect(user).to receive(:method)
          expect(user).to receive(:other_method)
        end
      end
    RUBY
  end

  it 'ignores `each` with expectation on property' do
    expect_no_offenses(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| expect(user.name).to be }
      end
    RUBY
  end

  it 'ignores assignments in the iteration' do
    expect_no_offenses(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each { |user| array = array.concat(user) }
      end
    RUBY
  end

  it 'ignores `each` when there is a negative expectation' do
    expect_no_offenses(<<~RUBY)
      it 'validates users' do
        [user1, user2, user3].each do |user|
          expect(user).not_to receive(:method)
          expect(user).to receive(:other_method)
        end
      end
    RUBY
  end

  context 'when Ruby 2.7', :ruby27 do
    it 'flags `each` with an expectation' do
      expect_offense(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { expect(_1).to be_valid }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'validates users' do
          expect([user1, user2, user3]).to all(be_valid)
        end
      RUBY
    end

    it 'flags `each` when expectation calls method with arguments' do
      expect_offense(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { expect(_1).to be_a(User) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'validates users' do
          expect([user1, user2, user3]).to all(be_a(User))
        end
      RUBY
    end

    it 'ignores `each` without expectation' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { allow(_1).to receive(:method) }
        end
      RUBY
    end

    it 'flags `each` with multiple expectations' do
      expect_offense(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
            expect(_1).to receive(:method)
            expect(_1).to receive(:other_method)
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'ignore `each` when the body does not contain only expectations' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each do
            allow(Something).to receive(:method).and_return(_1)
            expect(_1).to receive(:method)
            expect(_1).to receive(:other_method)
          end
        end
      RUBY
    end

    it 'ignores `each` with expectation on property' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { expect(_1.name).to be }
        end
      RUBY
    end

    it 'ignores assignments in the iteration' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { array = array.concat(_1) }
        end
      RUBY
    end

    it 'ignores `each` when there is a negative expectation' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each do
            expect(_1).not_to receive(:method)
            expect(_1).to receive(:other_method)
          end
        end
      RUBY
    end
  end

  context 'when Ruby 3.4', :ruby34 do
    it 'flags `each` with an expectation' do
      expect_offense(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { expect(it).to be_valid }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'validates users' do
          expect([user1, user2, user3]).to all(be_valid)
        end
      RUBY
    end

    it 'flags `each` when expectation calls method with arguments' do
      expect_offense(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { expect(it).to be_a(User) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'validates users' do
          expect([user1, user2, user3]).to all(be_a(User))
        end
      RUBY
    end

    it 'ignores `each` without expectation' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { allow(it).to receive(:method) }
        end
      RUBY
    end

    it 'flags `each` with multiple expectations' do
      expect_offense(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using the `all` matcher instead of iterating over an array.
            expect(it).to receive(:method)
            expect(it).to receive(:other_method)
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'ignore `each` when the body does not contain only expectations' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each do
            allow(Something).to receive(:method).and_return(it)
            expect(it).to receive(:method)
            expect(it).to receive(:other_method)
          end
        end
      RUBY
    end

    it 'ignores `each` with expectation on property' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { expect(it.name).to be }
        end
      RUBY
    end

    it 'ignores assignments in the iteration' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each { array = array.concat(it) }
        end
      RUBY
    end

    it 'ignores `each` when there is a negative expectation' do
      expect_no_offenses(<<~RUBY)
        it 'validates users' do
          [user1, user2, user3].each do
            expect(it).not_to receive(:method)
            expect(it).to receive(:other_method)
          end
        end
      RUBY
    end
  end
end
