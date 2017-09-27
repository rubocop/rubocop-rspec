RSpec.describe RuboCop::Cop::RSpec::Capybara::FeatureMethods do
  subject(:cop) { described_class.new }

  it 'flags violations for `background`' do
    expect_offense(<<-RUBY)
      background do; end
      ^^^^^^^^^^ Use `before` instead of `background`.
    RUBY
  end

  it 'flags violations for `scenario`' do
    expect_offense(<<-RUBY)
      scenario 'Foo' do; end
      ^^^^^^^^ Use `it` instead of `scenario`.
    RUBY
  end

  it 'flags violations for `xscenario`' do
    expect_offense(<<-RUBY)
      RSpec.xscenario 'Foo' do; end
            ^^^^^^^^^ Use `xit` instead of `xscenario`.
    RUBY
  end

  it 'flags violations for `given`' do
    expect_offense(<<-RUBY)
      given(:foo) { :foo }
      ^^^^^ Use `let` instead of `given`.
    RUBY
  end

  it 'flags violations for `given!`' do
    expect_offense(<<-RUBY)
      given!(:foo) { :foo }
      ^^^^^^ Use `let!` instead of `given!`.
    RUBY
  end

  it 'flags violations for `feature`' do
    expect_offense(<<-RUBY)
      RSpec.feature 'Foo' do; end
            ^^^^^^^ Use `describe` instead of `feature`.
    RUBY
  end

  it 'ignores variables inside examples' do
    expect_no_offenses(<<-RUBY)
      it 'is valid code' do
        given(feature)
        assign(background)
        run scenario
      end
    RUBY
  end

  include_examples 'autocorrect', 'background { }',    'before { }'
  include_examples 'autocorrect', 'scenario { }',      'it { }'
  include_examples 'autocorrect', 'xscenario { }',     'xit { }'
  include_examples 'autocorrect', 'given(:foo) { }',   'let(:foo) { }'
  include_examples 'autocorrect', 'given!(:foo) { }',  'let!(:foo) { }'
  include_examples 'autocorrect', 'RSpec.feature { }', 'RSpec.describe { }'
end
