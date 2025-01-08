# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RedundantContext do
  it 'registers an offense when single example inside context' do
    expect_offense(<<~RUBY)
      context 'when condition' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant context with single example.
        it 'does something' do
        end
      end
    RUBY
  end

  it 'does not register offense when multiple examples inside context' do
    expect_no_offenses(<<~RUBY)
      context 'when condition' do
        it 'does something' do
        end

        it 'does something else' do
        end
      end
    RUBY
  end
end
