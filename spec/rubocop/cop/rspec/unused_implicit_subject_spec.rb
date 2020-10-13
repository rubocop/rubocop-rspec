# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::UnusedImplicitSubject, :config do
  context 'with a subject that can be used implicitly' do
    it 'flags expect(that_subject)' do
      expect_offense(<<-RUBY)
        subject(:example) {}
        it { expect(example).to be_good }
             ^^^^^^^^^^^^^^^ Use implicit subject.
      RUBY

      expect_correction(<<-RUBY)
        subject(:example) {}
        it { is_expected.to be_good }
      RUBY
    end

    it 'flags that_subject.should' do
      expect_offense(<<-RUBY)
        subject(:example) {}
        it { example.should be_good }
             ^^^^^^^^^^^^^^ Use implicit subject.
        it { example.should == 42 }
             ^^^^^^^^^^^^^^ Use implicit subject.
      RUBY

      expect_correction(<<-RUBY)
        subject(:example) {}
        it { should be_good }
        it { should == 42 }
      RUBY
    end
  end

  context 'with a subject that can not be used implicitly' do
    it 'does not flag similar cases' do
      expect_no_offenses(<<-RUBY)
        let(:example) {}
        it { expect(example).to be_good }
        it { example.should be_good }
      RUBY
    end

    it 'does not flag non-simplifyable cases' do
      expect_no_offenses(<<-RUBY)
        subject(:example) {}
        it { expect(example.foo).to be_good }
        it { example.foo.should be_good }
        it { expect { example }.to be_good }
      RUBY
    end
  end
end
