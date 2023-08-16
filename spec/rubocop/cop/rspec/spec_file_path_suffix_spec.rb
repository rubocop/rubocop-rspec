# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SpecFilePathSuffix do
  def expect_global_offense(source, file = nil, message = '')
    processed_source = parse_source(source, file)
    offenses = _investigate(cop, processed_source)
    expect(offenses.size).to eq(1)
    expect(offenses.first.message).to eq(message)
  end

  def expect_no_global_offenses(source, file = nil)
    processed_source = parse_source(source, file)
    offenses = _investigate(cop, processed_source)
    expect(offenses.size).to eq(0)
  end

  let(:message) { 'Spec path should end with `_spec.rb`.' }

  it 'registers an offense for a repeated .rb' do
    expect_global_offense(<<~RUBY, 'my_class/foo_spec.rb.rb', message)
      describe MyClass, '#foo' do; end
    RUBY
  end

  it 'registers an offense for a file missing a .rb' do
    expect_global_offense(<<~RUBY, 'my_class/foo_specorb', message)
      describe MyClass, '#foo' do; end
    RUBY
  end

  it 'registers an offense for a file missing _spec' do
    expect_global_offense(<<~RUBY, 'spec/models/user.rb', message)
      describe User, '#foo' do; end
    RUBY
  end

  it 'registers an offense for a feature file missing _spec' do
    expect_global_offense(<<~RUBY, 'spec/features/my_feature.rb', message)
      feature "my feature" do; end
    RUBY
  end

  it 'registers an offense for a file without the .rb extension' do
    expect_global_offense(<<~RUBY, 'spec/models/user_specxrb', message)
      describe User do; end
    RUBY
  end

  it 'does not register an offense for shared examples' do
    expect_no_global_offenses(<<-RUBY, 'spec/models/user.rb')
      shared_examples_for 'foo' do; end
    RUBY
  end
end
