# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SubjectDeclaration do
  shared_examples 'flag unclear subject declaration' do |subject|
    context "when #{subject.inspect} is declared" do
      context 'with `let!` helper' do
        it 'is an offense without a block pass' do
          expect_offense(<<~RUBY, subject: subject.inspect)
            let!(%{subject}) { 'some subject' }
            ^^^^^^{subject}^ Use subject explicitly rather than using let
          RUBY

          expect_correction(<<~RUBY)
            subject! { 'some subject' }
          RUBY
        end

        it 'is an offense with a block pass' do
          expect_offense(<<~RUBY, subject: subject.inspect)
            let!(%{subject}, &block)
            ^^^^^^{subject}^^^^^^^^^ Use subject explicitly rather than using let
          RUBY

          expect_correction(<<~RUBY)
            subject!(&block)
          RUBY
        end
      end

      context 'with `let` helper' do
        it 'is an offense without a block pass' do
          expect_offense(<<~RUBY, subject: subject.inspect)
            let(%{subject}) { 'some subject' }
            ^^^^^{subject}^ Use subject explicitly rather than using let
          RUBY

          expect_correction(<<~RUBY)
            subject { 'some subject' }
          RUBY
        end

        it 'is an offense with a block pass' do
          expect_offense(<<~RUBY, subject: subject.inspect)
            let(%{subject}, &block)
            ^^^^^{subject}^^^^^^^^^ Use subject explicitly rather than using let
          RUBY

          expect_correction(<<~RUBY)
            subject(&block)
          RUBY
        end
      end

      it 'is an offense when declared redundantly with `subject`' do
        expect_offense(<<~RUBY, subject: subject.inspect)
          subject(%{subject}) { 'some subject' }
          ^^^^^^^^^{subject}^ Ambiguous declaration of subject
        RUBY

        expect_correction(<<~RUBY)
          subject { 'some subject' }
        RUBY
      end

      it 'is an offense when declared redundantly with `subject!`' do
        expect_offense(<<~RUBY, subject: subject.inspect)
          subject!(%{subject}) { 'some subject' }
          ^^^^^^^^^^{subject}^ Ambiguous declaration of subject
        RUBY

        expect_correction(<<~RUBY)
          subject! { 'some subject' }
        RUBY
      end
    end
  end

  it_behaves_like 'flag unclear subject declaration', :subject
  it_behaves_like 'flag unclear subject declaration', 'subject'
  it_behaves_like 'flag unclear subject declaration', :subject!
  it_behaves_like 'flag unclear subject declaration', 'subject!'

  context 'when subject helper is used directly' do
    it 'does not register an offense on named subject' do
      expect_no_offenses(<<~RUBY)
        subject(:foo) { 'bar' }
      RUBY
    end

    it 'does not register an offense on named `subject!`' do
      expect_no_offenses(<<~RUBY)
        subject!(:foo) { 'bar' }
      RUBY
    end

    it 'does not register an offense on subject with no name' do
      expect_no_offenses(<<~RUBY)
        subject { 'some subject' }
      RUBY
    end
  end

  context 'when subject is not declared' do
    it 'does not register an offense when `let` is used' do
      expect_no_offenses(<<~RUBY)
        let(:foo) { 'bar' }
      RUBY
    end

    it 'does not register an offense when `let!` is used' do
      expect_no_offenses(<<~RUBY)
        let!(:foo) { 'bar' }
      RUBY
    end
  end
end
