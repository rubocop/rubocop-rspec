# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MemoizedMatcher do
  it 'flags memoized matchers' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        it { is_expected.to eq_one }
      end
    RUBY
  end

  it 'ignores memoized helpers when not used in an expectation' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
        it { is_expected.to be_ok }
      end
    RUBY
  end

  it 'ignores memoized helpers when used as an actual' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let(:one) { eq(1) }
        it { expect(one).to be_match(1) }
      end
    RUBY
  end

  it 'flags memoized matchers on all levels' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        context do
          it { is_expected.to eq_one }
        end
      end
    RUBY
  end

  it 'flags memoized matchers when `expect` is used' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        it { expect(1).to eq_one }
      end
    RUBY
  end

  it 'flags memoized matchers with a failure message in expectation' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        it { is_expected.to eq_one, 'not one' }
      end
    RUBY
  end

  it 'flags memoized matchers with block expectations' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:change_something) { change { something } }
                                 ^^^^^^^^^^^^^^^^^^^^ Do not memoize matchers
        it do
          expect { nothing }.to change_something
        end
      end
    RUBY
  end

  it 'flags memoized matchers used in an compound expectation' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        it { is_expected.to be_positive.and eq_one }
      end
    RUBY
  end

  it 'flags memoized argument matchers' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        it { is_expected.to contain_exactly(eq_one) }
      end
    RUBY
  end

  it 'flags memoized matchers defined using a string' do
    expect_offense(<<~RUBY)
      describe Foo do
        let('eq_one') { eq(1) }
                        ^^^^^ Do not memoize matchers
        it { is_expected.to eq_one }
      end
    RUBY
  end

  it 'flags several memoized matchers' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:something) { 1 }
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        let(:eq_two) { eq(2) }
                       ^^^^^ Do not memoize matchers
        it { is_expected.to eq_one }
        it { is_expected.to eq_two }
        it { is_expected.to be_true }
      end
    RUBY
  end

  it 'flags a named `subject` used as a matcher' do
    expect_offense(<<~RUBY)
      describe Foo do
        subject(:eq_one) { eq(1) }
                           ^^^^^ Do not memoize matchers
        it { is_expected.to eq_one }
      end
    RUBY
  end

  it 'flags memoized matchers with `expect_any_instance_of`' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:become_closed) { receive(:close!).with(:immediately) }
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not memoize matchers
        it { expect_any_instance_of(Office).to become_closed }
      end
    RUBY
  end

  it 'flags memoized matchers used in a nested example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:eq_one) { eq(1) }
                       ^^^^^ Do not memoize matchers
        context 'at the bar' do
          it { is_expected.to eq_one }
        end
      end
    RUBY
  end
end
