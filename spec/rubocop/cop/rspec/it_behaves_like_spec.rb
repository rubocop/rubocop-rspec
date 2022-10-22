# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ItBehavesLike do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'when the enforced style is `it_behaves_like`' do
    let(:enforced_style) do
      :it_behaves_like
    end

    it 'flags a violation for it_should_behave_like' do
      expect_offense(<<-RUBY)
        it_should_behave_like 'a foo'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `it_behaves_like` over `it_should_behave_like` when including examples in a nested context.
      RUBY

      expect_correction(<<-RUBY)
        it_behaves_like 'a foo'
      RUBY
    end

    it 'does not flag a violation for it_behaves_like' do
      expect_no_offenses("it_behaves_like 'a foo'")
    end
  end

  context 'when the enforced style is `it_should_behave_like`' do
    let(:enforced_style) do
      :it_should_behave_like
    end

    it 'flags a violation for it_behaves_like' do
      expect_offense(<<-RUBY)
        it_behaves_like 'a foo'
        ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `it_should_behave_like` over `it_behaves_like` when including examples in a nested context.
      RUBY

      expect_correction(<<-RUBY)
        it_should_behave_like 'a foo'
      RUBY
    end

    it 'does not flag a violation for it_behaves_like' do
      expect_no_offenses("it_should_behave_like 'a foo'")
    end
  end
end
