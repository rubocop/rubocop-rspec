# encoding: utf-8

describe RuboCop::Cop::RSpec::HookArgument, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  let(:enforced_style) { :implicit }

  shared_examples 'ignored hooks' do
    it 'ignores :context and :suite' do
      expect_no_violations(<<-RUBY)
        before(:suite) { true }
        after(:suite) { true }
        before(:context) { true }
        after(:context) { true }
      RUBY
    end

    it 'ignores hooks with more than one argument' do
      expect_no_violations(<<-RUBY)
        before(:each, :something_custom) { true }
      RUBY
    end

    it 'ignores non-rspec hooks' do
      expect_no_violations(<<-RUBY)
        setup(:each) { true }
      RUBY
    end
  end

  shared_examples 'generated config' do |source, detected_style|
    it 'generates a todo based on the detected style' do
      inspect_source(cop, source, 'foo_spec.rb')

      expect(cop.config_to_allow_offenses)
        .to eq('EnforcedStyle' => detected_style)
    end
  end

  shared_examples 'hook autocorrect' do |output|
    it 'autocorrects :each to EnforcedStyle' do
      corrected =
        autocorrect_source(cop, 'before(:each) { }', 'spec/foo_spec.rb')

      expect(corrected).to eql(output)
    end

    it 'autocorrects :example to EnforcedStyle' do
      corrected =
        autocorrect_source(cop, 'before(:example) { }', 'spec/foo_spec.rb')

      expect(corrected).to eql(output)
    end

    it 'autocorrects :implicit to EnforcedStyle' do
      corrected =
        autocorrect_source(cop, 'before { }', 'spec/foo_spec.rb')

      expect(corrected).to eql(output)
    end
  end

  shared_examples 'an example hook' do
    include_examples 'ignored hooks'
    include_examples 'generated config', 'before(:each) { foo }', 'each'
    include_examples 'generated config', 'before(:example) { foo }', 'example'
    include_examples 'generated config', 'before { foo }', 'implicit'
  end

  context 'when EnforcedStyle is :implicit' do
    let(:enforced_style) { :implicit }

    it 'detects :each for hooks' do
      expect_violation(<<-RUBY)
        before(:each) { true }
        ^^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
        after(:each)  { true }
        ^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
        around(:each) { true }
        ^^^^^^^^^^^^^ Omit the default `:each` argument for RSpec hooks.
      RUBY
    end

    it 'detects :example for hooks' do
      expect_violation(<<-RUBY)
        before(:example) { true }
        ^^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
        after(:example)  { true }
        ^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
        around(:example) { true }
        ^^^^^^^^^^^^^^^^ Omit the default `:example` argument for RSpec hooks.
      RUBY
    end

    it 'does not flag hooks without default scopes' do
      expect_no_violations(<<-RUBY)
        before { true }
        after { true }
        before { true }
        after { true }
      RUBY
    end

    include_examples 'an example hook'
    include_examples 'hook autocorrect', 'before { }'
  end

  context 'when EnforcedStyle is :each' do
    let(:enforced_style) { :each }

    it 'detects :each for hooks' do
      expect_no_violations(<<-RUBY)
        before(:each) { true }
        after(:each)  { true }
        around(:each) { true }
      RUBY
    end

    it 'detects :example for hooks' do
      expect_violation(<<-RUBY)
        before(:example) { true }
        ^^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
        after(:example)  { true }
        ^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
        around(:example) { true }
        ^^^^^^^^^^^^^^^^ Use `:each` for RSpec hooks.
      RUBY
    end

    it 'does not flag hooks without default scopes' do
      expect_violation(<<-RUBY)
        before { true }
        ^^^^^^ Use `:each` for RSpec hooks.
        after { true }
        ^^^^^ Use `:each` for RSpec hooks.
        before { true }
        ^^^^^^ Use `:each` for RSpec hooks.
        after { true }
        ^^^^^ Use `:each` for RSpec hooks.
      RUBY
    end

    include_examples 'an example hook'
    include_examples 'hook autocorrect', 'before(:each) { }'
  end

  context 'when EnforcedStyle is :example' do
    let(:enforced_style) { :example }

    it 'detects :example for hooks' do
      expect_no_violations(<<-RUBY)
        before(:example) { true }
        after(:example)  { true }
        around(:example) { true }
      RUBY
    end

    it 'detects :each for hooks' do
      expect_violation(<<-RUBY)
        before(:each) { true }
        ^^^^^^^^^^^^^ Use `:example` for RSpec hooks.
        after(:each)  { true }
        ^^^^^^^^^^^^ Use `:example` for RSpec hooks.
        around(:each) { true }
        ^^^^^^^^^^^^^ Use `:example` for RSpec hooks.
      RUBY
    end

    it 'does not flag hooks without default scopes' do
      expect_violation(<<-RUBY)
        before { true }
        ^^^^^^ Use `:example` for RSpec hooks.
        after { true }
        ^^^^^ Use `:example` for RSpec hooks.
        before { true }
        ^^^^^^ Use `:example` for RSpec hooks.
        after { true }
        ^^^^^ Use `:example` for RSpec hooks.
      RUBY
    end

    include_examples 'an example hook'
    include_examples 'hook autocorrect', 'before(:example) { }'
  end
end
