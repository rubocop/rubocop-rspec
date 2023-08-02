# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Pending do
  let(:allowed_patterns) { [] }
  let(:allowed_identifiers) { [] }
  let(:cop_config) do
    {
      'AllowedIdentifiers' => allowed_identifiers,
      'AllowedPatterns' => allowed_patterns
    }
  end

  it 'flags it without body' do
    expect_offense(<<-RUBY)
      it 'test'
      ^^^^^^^^^ Pending spec found.
    RUBY
  end

  it 'flags it without body inside describe block' do
    expect_offense(<<-RUBY)
      describe 'test' do
        it 'test'
        ^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xcontext' do
    expect_offense(<<-RUBY)
      xcontext 'test' do
      ^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xdescribe' do
    expect_offense(<<-RUBY)
      xdescribe 'test' do
      ^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xexample' do
    expect_offense(<<-RUBY)
      xexample 'test' do
      ^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xfeature' do
    expect_offense(<<-RUBY)
      xfeature 'test' do
      ^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xit' do
    expect_offense(<<-RUBY)
      xit 'test' do
      ^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xscenario' do
    expect_offense(<<-RUBY)
      xscenario 'test' do
      ^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags xspecify' do
    expect_offense(<<-RUBY)
      xspecify 'test' do
      ^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags skip inside of an it' do
    expect_offense(<<-RUBY)
      it 'test' do
        skip
        ^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags skip blocks' do
    expect_offense(<<-RUBY)
      skip 'test' do
      ^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags blocks with skip symbol metadata' do
    expect_offense(<<-RUBY)
      it 'test', :skip do
      ^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags describe with skip symbol metadata' do
    expect_offense(<<-RUBY)
      RSpec.describe 'test', :skip do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags blocks with pending symbol metadata' do
    expect_offense(<<-RUBY)
      it 'test', :pending do
      ^^^^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags blocks with pending: string metadata and line break by `\`' do
    expect_offense(<<-'RUBY')
      it "test", pending: 'test' \
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pending spec found.
                          'foo' do
      end
    RUBY
  end

  it 'flags blocks with pending: string metadata and line break by `,`' do
    expect_offense(<<-RUBY)
      it "test", pending: 'test ,
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pending spec found.
                          foo' do
      end
    RUBY
  end

  it 'flags blocks with pending: surrounded by `%()` string metadata ' \
     'and line break' do
    expect_offense(<<-RUBY)
      it "test", pending: %(test ,
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pending spec found.
                          foo) do
      end
    RUBY
  end

  it 'flags blocks with skip: true metadata' do
    expect_offense(<<-RUBY)
      it 'test', skip: true do
      ^^^^^^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags blocks with skip: string metadata' do
    expect_offense(<<-RUBY)
      it 'test', skip: 'skipped because of being slow' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'flags pending blocks' do
    expect_offense(<<-RUBY)
      pending 'test' do
      ^^^^^^^^^^^^^^ Pending spec found.
      end
    RUBY
  end

  it 'ignores describe' do
    expect_no_offenses(<<-RUBY)
      describe 'test' do; end
    RUBY
  end

  it 'ignores example' do
    expect_no_offenses(<<-RUBY)
      example 'test' do; end
    RUBY
  end

  it 'ignores scenario' do
    expect_no_offenses(<<-RUBY)
      scenario 'test' do; end
    RUBY
  end

  it 'ignores specify' do
    expect_no_offenses(<<-RUBY)
      specify do; end
    RUBY
  end

  it 'ignores feature' do
    expect_no_offenses(<<-RUBY)
      feature 'test' do; end
    RUBY
  end

  it 'ignores context' do
    expect_no_offenses(<<-RUBY)
      context 'test' do; end
    RUBY
  end

  it 'ignores it' do
    expect_no_offenses(<<-RUBY)
      it 'test' do; end
    RUBY
  end

  it 'ignores it with skip: false metadata' do
    expect_no_offenses(<<-RUBY)
      it 'test', skip: false do; end
    RUBY
  end

  it 'ignores example_group' do
    expect_no_offenses(<<-RUBY)
      example_group 'test' do; end
    RUBY
  end

  it 'ignores method called pending' do
    expect_no_offenses(<<-RUBY)
      subject { Project.pending }
    RUBY
  end

  context 'when AllowedIdentifiers is set' do
    let(:allowed_identifiers) { %w[it xcontext] }

    it 'ignores allowed indexed let' do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          it
          xcontext 'test' do
          end
        end
      RUBY
    end
  end

  context 'when AllowedPatterns is set' do
    let(:allowed_patterns) { %w[it] }

    it 'ignores allowed indexed let' do
      expect_no_offenses(<<~RUBY)
        describe SomeService do
          it
          xit 'test' do
          end
        end
      RUBY
    end
  end
end
