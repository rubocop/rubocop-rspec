# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExampleWithoutDescription do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'with EnforcedStyle `always_allow`' do
    let(:enforced_style) do
      'always_allow'
    end

    it 'flags empty strings for description' do
      expect_offense(<<-RUBY)
        it '' do
           ^^ Omit the argument when you want to have auto-generated description.
          expect(subject).to be_good
        end
      RUBY
    end

    it 'ignores `it` with a description' do
      expect_no_offenses(<<-RUBY)
        it 'is good' do
          expect(subject).to be_good
        end
      RUBY
    end

    it 'ignores `it` without an argument' do
      expect_no_offenses(<<-RUBY)
        it do
          expect(subject).to be_good
        end
      RUBY
    end
  end

  context 'with EnforcedStyle `single_line_only`' do
    let(:enforced_style) do
      'single_line_only'
    end

    it 'flags missing description in multi-line examples' do
      expect_offense(<<-RUBY)
        it do
        ^^ Add a description.
          expect(subject).to be_good
        end
      RUBY
    end

    it 'ignores missing description in single-line examples' do
      expect_no_offenses(<<-RUBY)
        it { expect(subject).to be_good }
      RUBY
    end

    it 'flags example with an empty string for description' do
      expect_offense(<<-RUBY)
        it('') { expect(subject).to be_good }
           ^^ Omit the argument when you want to have auto-generated description.
      RUBY
    end
  end

  context 'with EnforcedStyle `disallow`' do
    let(:enforced_style) do
      'disallow'
    end

    it 'flags missing description in multi-line examples' do
      expect_offense(<<-RUBY)
        it do
        ^^ Add a description.
          expect(subject).to be_good
        end
      RUBY
    end

    it 'flags missing description in single-line examples' do
      expect_offense(<<-RUBY)
        it { expect(subject).to be_good }
        ^^ Add a description.
      RUBY
    end

    it 'ignores `it` with a description' do
      expect_no_offenses(<<-RUBY)
        it 'is good' do
          expect(subject).to be_good
        end
      RUBY
    end
  end
end
