# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Capybara::NegationMatcher, :config do
  let(:cop_config) { { 'EnforcedStyle' => enforced_style } }

  context 'with EnforcedStyle `have_no`' do
    let(:enforced_style) { 'have_no' }

    %i[selector css xpath text title current_path link button
       field checked_field unchecked_field select table
       sibling ancestor].each do |matcher|
      it 'registers an offense when using ' \
         '`expect(...).not_to have_#{matcher}`' do
        expect_offense(<<~RUBY, matcher: matcher)
          expect(page).not_to have_#{matcher}
                       ^^^^^^^^^^^^^{matcher} Use `expect(...).to have_no_#{matcher}`.
          expect(page).not_to have_#{matcher}('a')
                       ^^^^^^^^^^^^^{matcher} Use `expect(...).to have_no_#{matcher}`.
        RUBY

        expect_correction(<<~RUBY)
          expect(page).to have_no_#{matcher}
          expect(page).to have_no_#{matcher}('a')
        RUBY
      end

      it 'does not register an offense when using ' \
         '`expect(...).to have_no_#{matcher}`' do
        expect_no_offenses(<<~RUBY)
          expect(page).to have_no_#{matcher}
        RUBY
      end
    end

    it 'registers an offense when using ' \
       '`expect(...).not_to have_text` with heredoc' do
      expect_offense(<<~RUBY)
        expect(page).not_to have_text(exact_text: <<~TEXT)
                     ^^^^^^^^^^^^^^^^ Use `expect(...).to have_no_text`.
          foo
        TEXT
      RUBY

      expect_correction(<<~RUBY)
        expect(page).to have_no_text(exact_text: <<~TEXT)
          foo
        TEXT
      RUBY
    end
  end

  context 'with EnforcedStyle `not_to`' do
    let(:enforced_style) { 'not_to' }

    %i[selector css xpath text title current_path link button
       field checked_field unchecked_field select table
       sibling ancestor].each do |matcher|
      it 'registers an offense when using ' \
         '`expect(...).to have_no_#{matcher}`' do
        expect_offense(<<~RUBY, matcher: matcher)
          expect(page).to have_no_#{matcher}
                       ^^^^^^^^^^^^{matcher} Use `expect(...).not_to have_#{matcher}`.
          expect(page).to have_no_#{matcher}('a')
                       ^^^^^^^^^^^^{matcher} Use `expect(...).not_to have_#{matcher}`.
        RUBY

        expect_correction(<<~RUBY)
          expect(page).not_to have_#{matcher}
          expect(page).not_to have_#{matcher}('a')
        RUBY
      end

      it 'does not register an offense when using ' \
         '`expect(...).not_to have_#{matcher}`' do
        expect_no_offenses(<<~RUBY)
          expect(page).not_to have_#{matcher}
        RUBY
      end

      it 'registers an offense when using ' \
         '`expect(...).to have_no_text` with heredoc' do
        expect_offense(<<~RUBY)
          expect(page).to have_no_text(exact_text: <<~TEXT)
                       ^^^^^^^^^^^^^^^ Use `expect(...).not_to have_text`.
            foo
          TEXT
        RUBY

        expect_correction(<<~RUBY)
          expect(page).not_to have_text(exact_text: <<~TEXT)
            foo
          TEXT
        RUBY
      end
    end
  end
end
