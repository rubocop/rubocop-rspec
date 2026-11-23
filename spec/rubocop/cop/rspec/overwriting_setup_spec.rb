# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::OverwritingSetup do
  it 'registers an offense for overwritten `let`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for overwritten `subject`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject(:a) { a }

        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for `subject!` and `let!`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject!(:a) { a }

        let!(:a) { b }
        ^^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for `let!` overwriting `let`' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { b }
        let!(:a) { b }
        ^^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'does not register an offense for overwriting in different context' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a) { a }

        context `different` do
          let(:a) { b }
        end
      end
    RUBY
  end

  it 'registers an offense for overriding an unnamed subject' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject { a }

        let(:subject) { b }
        ^^^^^^^^^^^^^^^^^^^ `subject` is already defined.
      end
    RUBY
  end

  it 'does not register an offense for dynamic names for `let`' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        subject(:name) { a }

        let(name) { b }
      end
    RUBY
  end

  it 'registers an offense for string arguments' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject(:name) { a }

        let("name") { b }
        ^^^^^^^^^^^^^^^^^ `name` is already defined.
      end
    RUBY
  end

  it 'registers an offense for a block-pass let overwriting a let' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a) { b }
        let(:a, &blk)
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for a let overwriting a block-pass let' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        let(:a, &blk)
        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for a block-pass let overwriting a subject' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject(:a) { b }
        let!(:a, &blk)
        ^^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for a let overwriting a block-pass subject' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject(:a, &blk)
        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for repeated block-pass subjects' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject(&blk)
        subject(&other)
        ^^^^^^^^^^^^^^^ `subject` is already defined.
      end
    RUBY
  end

  it 'registers an offense for a block subject overwriting a block-pass one' do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        subject(&blk)
        subject { a }
        ^^^^^^^^^^^^^ `subject` is already defined.
      end
    RUBY
  end

  it 'ignores block-pass setups with different names' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:a, &blk)
        let(:b, &blk)
        subject(:c, &blk)
        subject(&blk)
      end
    RUBY
  end

  it 'ignores block-pass setups with non-literal arguments' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(name, &blk)
        let(name, &blk)
      end
    RUBY
  end
end
