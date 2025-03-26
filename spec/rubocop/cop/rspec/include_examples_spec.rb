# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::IncludeExamples, :config do
  it 'registers an offense and corrects for `include_examples`' do
    expect_offense(<<~RUBY)
      include_examples 'examples'
      ^^^^^^^^^^^^^^^^ Prefer `it_behaves_like` over `include_examples`.
    RUBY

    expect_correction(<<~RUBY)
      it_behaves_like 'examples'
    RUBY
  end

  it 'does not register an offense for `it_behaves_like`' do
    expect_no_offenses(<<~RUBY)
      it_behaves_like 'examples'
    RUBY
  end

  it 'does not register an offense for `it_should_behave_like`' do
    expect_no_offenses(<<~RUBY)
      it_should_behave_like 'examples'
    RUBY
  end

  it 'does not register an offense for `include_context`' do
    expect_no_offenses(<<~RUBY)
      include_context 'context'
    RUBY
  end
end
