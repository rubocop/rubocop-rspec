# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::HttpStatus do
  context 'when EnforcedStyle is `symbolic`' do
    let(:cop_config) { { 'EnforcedStyle' => 'symbolic' } }

    it 'registers an offense when using numeric value' do
      expect_offense(<<-RUBY)
        it { is_expected.to have_http_status 200 }
                                             ^^^ Prefer `:ok` over `200` to describe HTTP status code.
      RUBY

      expect_correction(<<-RUBY)
        it { is_expected.to have_http_status :ok }
      RUBY
    end

    it 'does not register an offense when using symbolic value' do
      expect_no_offenses(<<-RUBY)
        it { is_expected.to have_http_status :ok }
      RUBY
    end

    it 'does not register an offense when using custom HTTP code' do
      expect_no_offenses(<<-RUBY)
        it { is_expected.to have_http_status 550 }
      RUBY
    end

    context 'with parenthesis' do
      it 'registers an offense when using numeric value' do
        expect_offense(<<-RUBY)
          it { is_expected.to have_http_status(404) }
                                               ^^^ Prefer `:not_found` over `404` to describe HTTP status code.
        RUBY

        expect_correction(<<-RUBY)
          it { is_expected.to have_http_status(:not_found) }
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is `numeric`' do
    let(:cop_config) { { 'EnforcedStyle' => 'numeric' } }

    it 'registers an offense when using symbolic value' do
      expect_offense(<<-RUBY)
        it { is_expected.to have_http_status :ok }
                                             ^^^ Prefer `200` over `:ok` to describe HTTP status code.
      RUBY

      expect_correction(<<-RUBY)
        it { is_expected.to have_http_status 200 }
      RUBY
    end

    it 'does not register an offense when using numeric value' do
      expect_no_offenses(<<-RUBY)
        it { is_expected.to have_http_status 200 }
      RUBY
    end

    it 'does not register an offense when using allowed symbols' do
      expect_no_offenses(<<-RUBY)
        it { is_expected.to have_http_status :error }
        it { is_expected.to have_http_status :success }
        it { is_expected.to have_http_status :missing }
        it { is_expected.to have_http_status :redirect }
      RUBY
    end

    context 'with parenthesis' do
      it 'registers an offense when using symbolic value' do
        expect_offense(<<-RUBY)
          it { is_expected.to have_http_status(:not_found) }
                                               ^^^^^^^^^^ Prefer `404` over `:not_found` to describe HTTP status code.
        RUBY

        expect_correction(<<-RUBY)
          it { is_expected.to have_http_status(404) }
        RUBY
      end
    end
  end
end
