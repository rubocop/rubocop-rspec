# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MultipleSubjects do
  let(:cop) { described_class.new }

  it 'registers an offense for every overwritten subject' do
    expect_offense(<<-RUBY)
      describe 'hello there' do
        subject(:foo) { 1 }
        ^^^^^^^^^^^^^^^^^^^ Do not set more than one subject per example group
        subject(:bar) { 2 }
        ^^^^^^^^^^^^^^^^^^^ Do not set more than one subject per example group
        subject { 3 }
        ^^^^^^^^^^^^^ Do not set more than one subject per example group
        subject(:baz) { 4 }

        describe 'baz' do
          subject(:norf) { 1 }
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      describe 'hello there' do
        let(:foo) { 1 }
        let(:bar) { 2 }
        subject(:baz) { 4 }

        describe 'baz' do
          subject(:norf) { 1 }
        end
      end
    RUBY
  end

  it 'does not try to autocorrect subject!' do
    source = <<-RUBY
      describe Foo do
        subject! { a }
        ^^^^^^^^^^^^^^ Do not set more than one subject per example group
        subject! { b }
      end
    RUBY

    expect_offense(source)
    expect_no_corrections
  end

  it 'does not flag shared example groups' do
    expect_no_offenses(<<-RUBY)
      describe Foo do
        it_behaves_like 'user' do
          subject { described_class.new(user, described_class) }

          it { expect(subject).not_to be_accessible }
        end

        it_behaves_like 'admin' do
          subject { described_class.new(user, described_class) }

          it { expect(subject).to be_accessible }
        end
      end
    RUBY
  end

  it 'autocorrects' do
    expect_offense(<<-RUBY)
      describe 'hello there' do
        subject { 1 }
        ^^^^^^^^^^^^^ Do not set more than one subject per example group
        subject { 2 }
        ^^^^^^^^^^^^^ Do not set more than one subject per example group
        subject { 3 }
      end
    RUBY
    expect_correction(<<-RUBY)
      describe 'hello there' do
        subject { 3 }
      end
    RUBY
  end
end
