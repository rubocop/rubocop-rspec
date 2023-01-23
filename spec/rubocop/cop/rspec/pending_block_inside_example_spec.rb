# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::PendingBlockInsideExample, :config do
  context 'when using inside example' do
    it 'registers an offense when using `pending` with block passing' do
      expect_offense(<<~RUBY)
        it "does something" do
          pending 'not yet implemented' do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't pass a block to `pending` or `skip` inside examples.
          end
        end
      RUBY
    end

    it 'registers an offense when using `pending` with a numblock', :ruby27 do
      expect_offense(<<~RUBY)
        it "does something" do
          pending 'not yet implemented' do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't pass a block to `pending` or `skip` inside examples.
            _1
          end
        end
      RUBY
    end

    it 'registers an offense when using `skip` with block passing' do
      expect_offense(<<~RUBY)
        it "does something" do
          skip 'not yet implemented' do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't pass a block to `pending` or `skip` inside examples.
          end
        end
      RUBY
    end

    it 'does not register an offense when ' \
       'using `pending` without block passing' do
      expect_no_offenses(<<~RUBY)
        it "does something" do
          pending 'not yet implemented'
        end
      RUBY
    end

    it 'does not register an offense when using `skip` without block passing' do
      expect_no_offenses(<<~RUBY)
        it "does something" do
          skip 'not yet implemented'
        end
      RUBY
    end
  end

  context 'when using outside example' do
    it 'does not register an offense when using `pending`' do
      expect_no_offenses(<<~RUBY)
        pending 'not yet implemented' do
        end
      RUBY
    end

    it 'does not register an offense when using `skip`' do
      expect_no_offenses(<<~RUBY)
        skip 'not yet implemented' do
        end
      RUBY
    end
  end
end
