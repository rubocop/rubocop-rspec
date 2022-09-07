# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ClassCheck do
  context 'when EnforcedStyle is `be_a`' do
    context 'when `be_a` is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          expect(a).to be_a(b)
        RUBY
      end
    end

    context 'when `be_an` is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          expect(a).to be_an(b)
        RUBY
      end
    end

    context 'when `Foo.be_kind_of` is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Foo.be_kind_of(b)
        RUBY
      end
    end

    context 'when `be_kind_of` is used' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          expect(a).to be_kind_of(b)
                       ^^^^^^^^^^ Prefer `be_a` over `be_kind_of`.
        RUBY

        expect_correction(<<~RUBY)
          expect(a).to be_a(b)
        RUBY
      end
    end

    context 'when `be_a_kind_of` is used' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          expect(a).to be_a_kind_of(b)
                       ^^^^^^^^^^^^ Prefer `be_a` over `be_a_kind_of`.
        RUBY

        expect_correction(<<~RUBY)
          expect(a).to be_a(b)
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is `be_kind_of`' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'be_kind_of' }
    end

    context 'when `be_kind_of` is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          expect(a).to be_kind_of(b)
        RUBY
      end
    end

    context 'when `be_a_kind_of` is used' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          expect(a).to be_a_kind_of(b)
        RUBY
      end
    end

    context 'when `be_a` is used' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          expect(a).to be_a(b)
                       ^^^^ Prefer `be_kind_of` over `be_a`.
        RUBY

        expect_correction(<<~RUBY)
          expect(a).to be_kind_of(b)
        RUBY
      end
    end

    context 'when `be_an` is used' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          expect(a).to be_an(b)
                       ^^^^^ Prefer `be_kind_of` over `be_an`.
        RUBY

        expect_correction(<<~RUBY)
          expect(a).to be_kind_of(b)
        RUBY
      end
    end
  end
end
