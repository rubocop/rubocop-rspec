RSpec.describe RuboCop::Cop::RSpec::OverwritingSetup do
  subject(:cop) { described_class.new }

  it 'finds overwriten `let`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let(:a) { a }
        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'finds overwriten `subject`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject(:a) { a }

        let(:a) { b }
        ^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'finds `let!` overwriting `let`' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        let(:a) { b }
        let!(:a) { b }
        ^^^^^^^^^^^^^^ `a` is already defined.
      end
    RUBY
  end

  it 'ignores overwriting in different context' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        let(:a) { a }

        context `different` do
          let(:a) { b }
        end
      end
    RUBY
  end

  it 'does not encounter an error when handling an empty describe' do
    expect { inspect_source('RSpec.describe(User) do end', 'a_spec.rb') }
      .not_to raise_error
  end
end
