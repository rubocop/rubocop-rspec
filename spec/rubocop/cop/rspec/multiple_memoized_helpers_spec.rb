# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MultipleMemoizedHelpers do
  let(:cop_config) { { 'Max' => 1 } }

  it 'flags excessive `#let`' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        let(:foo) { Foo.new }
        let(:bar) { Bar.new }
      end
    RUBY
  end

  it 'flags excessive `#let!`' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        let(:foo) { Foo.new }
        let!(:bar) { Bar.new }
      end
    RUBY
  end

  it 'ignores a reasonable number of memoized helpers' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let(:foo) { Foo.new }
      end
    RUBY
  end

  it 'ignores overridden `#let`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let(:foo) { Foo.new }
        context do
          let(:foo) { Foo.new(1) }
          context do
            let(:foo) { Foo.new(1, 2) }
          end
        end
      end
    RUBY
  end

  it 'ignores `#subject`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        subject(:bar) { Bar.new }
        let(:foo) { Foo.new }
      end
    RUBY
  end

  it 'ignores `#subject!`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        subject!(:bar) { Bar.new }
        let(:foo) { Foo.new }
      end
    RUBY
  end

  it 'ignores `#subject` without a name' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        subject { Foo.new }
        let(:bar) { Bar.new }
      end
    RUBY
  end

  it 'flags nested `#let`' do
    expect_offense(<<~RUBY)
      describe Foo do
        let(:foo) { Foo.new }

        context 'when blah' do
        ^^^^^^^^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
          let(:bar) { Bar.new }
        end
      end
    RUBY
  end

  it 'ignores distributed `#let`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        context 'when bloo' do
          let(:foo) { Foo.new }
        end

        context 'when blah' do
          let(:bar) { Bar.new }
        end
      end
    RUBY
  end

  context 'when using AllowSubject configuration' do
    let(:cop_config) { { 'Max' => 1, 'AllowSubject' => false } }

    it 'flags `#subject` without name' do
      expect_offense(<<~RUBY)
        describe Foo do
        ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
          subject { Foo.new }
          let(:foo) { Foo.new }
        end
      RUBY
    end

    it 'flags `#subject`' do
      expect_offense(<<~RUBY)
        describe Foo do
        ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
          subject(:foo) { Foo.new }
          let(:bar) { Foo.new }
        end
      RUBY
    end

    it 'flags `#subject!`' do
      expect_offense(<<~RUBY)
        describe Foo do
        ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
          subject!(:foo) { Foo.new }
          let(:bar) { Foo.new }
        end
      RUBY
    end

    it 'ignores overridden subjects' do
      expect_no_offenses(<<~RUBY)
        describe Foo do
          subject { Foo.new }
          context do
            subject { Foo.new(1) }
            context do
              subject { Foo.new(1, 2) }
            end
          end
        end
      RUBY
    end
  end

  it 'support --auto-gen-config' do
    inspect_source(<<-RUBY, 'spec/foo_spec.rb')
      describe Foo do
        let(:foo) { Foo.new }
        let(:bar) { Bar.new }
        let(:baz) { Baz.new }
        let(:qux) { Qux.new }
      end
    RUBY

    expect(cop.config_to_allow_offenses[:exclude_limit]).to eq('Max' => 4)
  end
end
