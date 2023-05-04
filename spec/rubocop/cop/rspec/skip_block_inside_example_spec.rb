# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SkipBlockInsideExample, :config do
  it 'registers an offense when using `skip` with a block' do
    expect_offense(<<~RUBY)
      it 'does something' do
        skip 'not yet implemented' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't pass a block to `skip` inside examples.
        end
      end
    RUBY
  end

  it 'registers an offense when using `skip` with a numblock', :ruby27 do
    expect_offense(<<~RUBY)
      it 'does something' do
        skip 'not yet implemented' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't pass a block to `skip` inside examples.
          _1
        end
      end
    RUBY
  end

  it 'does not register an offense when using `skip` without a block' do
    expect_no_offenses(<<~RUBY)
      it 'does something' do
        skip 'not yet implemented'
      end
    RUBY
  end

  it 'does not register an offense outside examples' do
    expect_no_offenses(<<~RUBY)
      skip 'not yet implemented' do
      end
    RUBY
  end

  it 'does not register an offense when using `pending`' do
    # RSpec would through an ArgumentError
    expect_no_offenses(<<~RUBY)
      it 'does something' do
        pending 'not yet implemented' do
          # ...
        end
        foo 'dfdf' do
          # ...
        end
      end
    RUBY
  end
end
