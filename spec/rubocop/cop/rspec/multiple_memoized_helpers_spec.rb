# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::MultipleMemoizedHelpers, :config do
  let(:cop_config) { { 'Max' => 1 } }

  it 'flags an offense when using more than max `#let` calls' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        let(:foo) { Foo.new }
        let(:bar) { Bar.new }
      end
    RUBY
  end

  it 'flags an offense when using `#subject` without name' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        subject { Foo.new }
        let(:foo) { Foo.new }
      end
    RUBY
  end

  it 'flags an offense when using `#subject` with name' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        subject(:foo) { Foo.new }
        let(:bar) { Foo.new }
      end
    RUBY
  end

  it 'flags an offense when using `#let!`' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        let(:foo) { Foo.new }
        let!(:bar) { Foo.new }
      end
    RUBY
  end

  it 'flags an offense when using `#subject!`' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [2/1]
        subject!(:foo) { Foo.new }
        let(:bar) { Foo.new }
      end
    RUBY
  end

  it 'does not flag an offense when using <= max `#let` calls' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let(:foo) { Foo.new }
      end
    RUBY
  end

  it 'ignores overridden variables' do
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

  it 'ignores overridden nameless subjects' do
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

  it 'flags an offense when too many `#let` calls are nested' do
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

  it 'does not flag an offense when `#let` calls are distributed' do
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

  it 'does not flag an offense when using `#before`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before { foo }
      end
    RUBY
  end

  context 'when using AllowSubject configuration', :config do
    let(:cop_config) { { 'Max' => 0, 'AllowSubject' => true } }

    it 'flags an offense when using `#let`' do
      expect_offense(<<~RUBY)
        describe Foo do
        ^^^^^^^^^^^^^^^ Example group has too many memoized helpers [1/0]
          let(:foo) { Foo.new }
        end
      RUBY
    end

    it 'does not flag an offense when using `#subject` without a name' do
      expect_no_offenses(<<~RUBY)
        describe Foo do
          subject { Foo.new }
        end
      RUBY
    end

    it 'does not flag an offense when using `#subject` with a name' do
      expect_no_offenses(<<~RUBY)
        describe Foo do
          subject(:foo) { Foo.new }
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
