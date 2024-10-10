# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SortMetadata do
  it 'does not register an offense when using only symbol metadata ' \
     'in alphabetical order' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'Something', :a, :b do
      end
    RUBY
  end

  it 'registers an offense when using only symbol metadata, ' \
     'but not in alphabetical order' do
    expect_offense(<<~RUBY)
      RSpec.describe 'Something', :b, :a do
                                  ^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe 'Something', :a, :b do
      end
    RUBY
  end

  it 'does not register an offense for a symbol metadata before a non-symbol ' \
     'argument' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'Something', :z, :a, 'string' do
      end

      RSpec.describe 'Something', :z, :a, variable, foo: :bar do
      end
    RUBY
  end

  it 'registers an offense only for trailing symbol metadata not in ' \
     'alphabetical order' do
    expect_offense(<<~RUBY)
      RSpec.describe 'Something', :z, :a, 'string', :c, :b do
                                                    ^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe 'Something', :z, :a, 'string', :b, :c do
      end
    RUBY
  end

  it 'registers an offense when a symbol metadata not in alphabetical order ' \
     'is before a variable argument being the last argument ' \
     'as it could be a hash' do
    expect_offense(<<~RUBY)
      RSpec.describe 'Something', :z, :a, some_hash do
                                  ^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe 'Something', :a, :z, some_hash do
      end
    RUBY
  end

  it 'does not register an offense when using a second level description ' \
     'not in alphabetical order with symbol metadata' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe 'Something', 'second docstring', :a, :b do
      end
    RUBY
  end

  it 'does not register an offense when using only a hash of metadata ' \
     'with keys in alphabetical order' do
    expect_no_offenses(<<~RUBY)
      context 'Something', baz: true, foo: 'bar' do
      end
    RUBY
  end

  it 'registers an offense when using only a hash of metadata, ' \
     'but with keys not in alphabetical order' do
    expect_offense(<<~RUBY)
      context 'Something', foo: 'bar', baz: true do
                           ^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      context 'Something', baz: true, foo: 'bar' do
      end
    RUBY
  end

  it 'does not register an offense when using mixed metadata ' \
     'in alphabetical order (respectively)' do
    expect_no_offenses(<<~RUBY)
      it 'Something', :a, :b, baz: true, foo: 'bar' do
      end
    RUBY
  end

  it 'registers an offense when using mixed metadata, ' \
     'but only the hash keys are in alphabetical order' do
    expect_offense(<<~RUBY)
      it 'Something', :b, :a, baz: true, foo: 'bar' do
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'Something', :a, :b, baz: true, foo: 'bar' do
      end
    RUBY
  end

  it 'registers an offense when using mixed metadata, ' \
     'but only the symbol keys are in alphabetical order' do
    expect_offense(<<~RUBY)
      it 'Something', :a, :b, foo: 'bar', baz: true do
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'Something', :a, :b, baz: true, foo: 'bar' do
      end
    RUBY
  end

  it 'registers an offense when using mixed metadata ' \
     'and both symbols metadata and hash keys are not in alphabetical order' do
    expect_offense(<<~RUBY)
      it 'Something', :b, :a, foo: 'bar', baz: true do
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'Something', :a, :b, baz: true, foo: 'bar' do
      end
    RUBY
  end

  it 'registers an offense when using mixed metadata ' \
     'and both symbols metadata and hash keys are not in alphabetical order ' \
     'and the hash values are complex objects' do
    expect_offense(<<~RUBY)
      it 'Something', variable, 'B', :a, key => {}, foo: ->(x) { bar(x) }, Identifier.sample => true, baz: Snafu.new do
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      it 'Something', variable, 'B', :a, baz: Snafu.new, foo: ->(x) { bar(x) }, Identifier.sample => true, key => {} do
      end
    RUBY
  end

  it 'registers an offense only when example or group has a block' do
    expect_offense(<<~RUBY)
      shared_examples 'a difficult situation', 'B', :z, :a do |x, y|
                                                    ^^^^^^ Sort metadata alphabetically.
      end

      include_examples 'a difficult situation', 'value', 'another value'
    RUBY

    expect_correction(<<~RUBY)
      shared_examples 'a difficult situation', 'B', :a, :z do |x, y|
      end

      include_examples 'a difficult situation', 'value', 'another value'
    RUBY
  end

  it 'registers an offense also when the metadata is not on one single line' do
    expect_offense(<<~RUBY)
      RSpec.describe 'Something', :foo, :bar,
                                  ^^^^^^^^^^^ Sort metadata alphabetically.
                                   baz: 'goo' do
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe 'Something', :bar, :foo, baz: 'goo' do
      end
    RUBY
  end

  it 'registers an offense when using only symbol metadata ' \
     'in a config block, but not in alphabetical order' do
    expect_offense(<<~RUBY)
      RSpec.configure do |c|
        c.before(:each, :b, :a) { freeze_time }
                        ^^^^^^ Sort metadata alphabetically.
        c.after(:each, foo: 'bar', baz: true) { travel_back }
                       ^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.configure do |c|
        c.before(:each, :a, :b) { freeze_time }
        c.after(:each, baz: true, foo: 'bar') { travel_back }
      end
    RUBY
  end

  it "ignores includes' positional arguments" do
    expect_no_offenses(<<~RUBY)
      include_examples 'z', 'a' do
      end
      it_behaves_like 'z', 'a' do
      end
      include_context 'z', 'a' do
      end
    RUBY
  end

  context 'when using custom RSpec language ' \
          'without adjusting the RuboCop RSpec language configuration' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describan "Algo", :b, :a do
          contexto_compartido 'una situación complicada', foo: 'bar', baz: true do
          end

          ejemplo "hablando español", foo: 'bar', baz: true do
          end
        end
      RUBY
    end
  end

  context 'when using custom RSpec language ' \
          'and adjusting the RuboCop RSpec language configuration' do
    before do
      other_cops.tap do |config|
        config.dig('RSpec', 'Language', 'ExampleGroups', 'Regular').push(
          'describan', 'contexto_compartido'
        )
        config.dig('RSpec', 'Language', 'Examples', 'Regular').push('ejemplo')
      end
    end

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describan "Algo", :b, :a do
                                ^^^^^^ Sort metadata alphabetically.
          contexto_compartido 'una situación complicada', foo: 'bar', baz: true do
                                                          ^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
          end

          ejemplo "hablando español", foo: 'bar', baz: true do
                                      ^^^^^^^^^^^^^^^^^^^^^ Sort metadata alphabetically.
          end
        end
      RUBY
    end
  end
end
