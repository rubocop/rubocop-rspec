# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ImplicitSubject do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'with EnforcedStyle `single_line_only`' do
    let(:enforced_style) do
      'single_line_only'
    end

    it 'flags `is_expected` in multi-line examples' do
      expect_offense(<<-RUBY)
        it 'expect subject to be used' do
          is_expected.to be_good
          ^^^^^^^^^^^ Don't use implicit subject.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'expect subject to be used' do
          expect(subject).to be_good
        end
      RUBY
    end

    it 'allows `is_expected` inside `its` block, in multi-line examples' do
      expect_no_offenses(<<-RUBY)
        its(:quality) do
          is_expected.to be :high
        end
      RUBY
    end

    it 'flags `should` in multi-line examples' do
      expect_offense(<<-RUBY)
        it 'expect subject to be used' do
          should be_good
          ^^^^^^^^^^^^^^ Don't use implicit subject.
          should_not be_bad
          ^^^^^^^^^^^^^^^^^ Don't use implicit subject.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'expect subject to be used' do
          expect(subject).to be_good
          expect(subject).not_to be_bad
        end
      RUBY
    end

    it 'allows `is_expected` in single-line examples' do
      expect_no_offenses(<<-RUBY)
        it { is_expected.to be_good }
      RUBY
    end

    it 'allows `should` in single-line examples' do
      expect_no_offenses(<<-RUBY)
        it { should be_good }
      RUBY
    end

    it 'does not flag methods called is_expected and should' do
      expect_no_offenses(<<-RUBY)
        it 'uses some similar sounding methods' do
          expect(baz).to receive(:is_expected)
          baz.is_expected
          foo.should(deny_access)
        end
      RUBY
    end

    it 'detects usage of `is_expected` inside helper methods' do
      expect_offense(<<-RUBY)
        def permits(actions)
          actions.each { |action| is_expected.to permit_action(action) }
                                  ^^^^^^^^^^^ Don't use implicit subject.
        end
      RUBY

      expect_correction(<<-RUBY)
        def permits(actions)
          actions.each { |action| expect(subject).to permit_action(action) }
        end
      RUBY
    end
  end

  context 'with EnforcedStyle `single_statement_only`' do
    let(:enforced_style) do
      'single_statement_only'
    end

    it 'allows `is_expected` in multi-line example with single statement' do
      expect_no_offenses(<<-RUBY)
        it 'expect subject to be used' do
          is_expected.to be_good
        end
      RUBY
    end

    it 'flags `is_expected` in multi-statement examples' do
      expect_offense(<<-RUBY)
        it 'expect subject to be used' do
          subject.age = 18
          is_expected.to be_valid
          ^^^^^^^^^^^ Don't use implicit subject.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'expect subject to be used' do
          subject.age = 18
          expect(subject).to be_valid
        end
      RUBY
    end
  end

  context 'with EnforcedStyle `disallow`' do
    let(:enforced_style) do
      'disallow'
    end

    it 'flags `is_expected` in multi-line examples' do
      expect_offense(<<-RUBY)
        it 'expect subject to be used' do
          is_expected.to be_good
          ^^^^^^^^^^^ Don't use implicit subject.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'expect subject to be used' do
          expect(subject).to be_good
        end
      RUBY
    end

    it 'flags `is_expected` in single-line examples' do
      expect_offense(<<-RUBY)
        it { is_expected.to be_good }
             ^^^^^^^^^^^ Don't use implicit subject.
      RUBY

      expect_correction(<<-RUBY)
        it { expect(subject).to be_good }
      RUBY
    end

    it 'flags `should` in multi-line examples' do
      expect_offense(<<-RUBY)
        it 'expect subject to be used' do
          should be_good
          ^^^^^^^^^^^^^^ Don't use implicit subject.
          should_not be_bad
          ^^^^^^^^^^^^^^^^^ Don't use implicit subject.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'expect subject to be used' do
          expect(subject).to be_good
          expect(subject).not_to be_bad
        end
      RUBY
    end

    it 'flags `should` in single-line examples' do
      expect_offense(<<-RUBY)
        it { should be_good }
             ^^^^^^^^^^^^^^ Don't use implicit subject.
        it { should_not be_bad }
             ^^^^^^^^^^^^^^^^^ Don't use implicit subject.
      RUBY

      expect_correction(<<-RUBY)
        it { expect(subject).to be_good }
        it { expect(subject).not_to be_bad }
      RUBY
    end

    it 'allows `is_expected` inside `its` block' do
      expect_no_offenses(<<-RUBY)
        its(:quality) { is_expected.to be :high }
      RUBY
    end
  end

  context 'with EnforcedStyle `require_implicit`' do
    let(:enforced_style) do
      'require_implicit'
    end

    context 'with `is_expected`' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY)
          it { is_expected.to be_good }
        RUBY
      end
    end

    context 'with `expect { subject }`' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY)
          it { expect { subject }.to change(goodness, :count) }
        RUBY
      end
    end

    context 'with `its`' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY)
          its(:quality) { is_expected.to be(:high) }
        RUBY
      end
    end

    context 'with named subject' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY)
          subject(:instance) { described_class.new }

          it { expect(instance).to be_good }
        RUBY
      end
    end

    context 'with `expect(subject)` in one-line' do
      it 'registers and autocorrects an offense' do
        expect_offense(<<-RUBY)
          it { expect(subject).to be_good }
               ^^^^^^^^^^^^^^^ Don't use explicit subject.
        RUBY

        expect_correction(<<-RUBY)
          it { is_expected.to be_good }
        RUBY
      end
    end

    context 'with `expect(subject)` in multi-lines' do
      it 'registers and autocorrects an offense' do
        expect_offense(<<-RUBY)
          it do
            expect(subject).to be_good
            ^^^^^^^^^^^^^^^ Don't use explicit subject.
          end
        RUBY

        expect_correction(<<-RUBY)
          it do
            is_expected.to be_good
          end
        RUBY
      end
    end
  end
end
