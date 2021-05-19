# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::OverwritingSetup do
  it 'registers an offense for overwriten `let`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for overwriten `subject`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject(:a) { a }

        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for `subject!` and `let!`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject!(:a) { a }

        let!(:a) { b }
        ^^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'registers an offense for `let!` overwriting `let`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let(:a) { b }
        let!(:a) { b }
        ^^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'does not register an offense for overwriting in different context' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:a) { a }

        context `different` do
          let(:a) { b }
        end
      end
    RUBY
  end

  it 'registers an offense for overriding an unnamed subject' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject { a }

        let(:subject) { b }
        ^^^^^^^^^^^^^^^^^^^ `subject` is already defined.
      end
    RUBY
  end

  it 'does not register an offense for dynamic names for `let`' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject(:name) { a }

        let(name) { b }
      end
    RUBY
  end

  it 'registers an offense for string arguments' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject(:name) { a }

        let("name") { b }
        ^^^^^^^^^^^^^^^^^ `name` is already defined.
      end
    RUBY
  end
end
