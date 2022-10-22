# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::VerifiedDoubles do
  it 'finds a `double` instead of an `instance_double`' do
    expect_offense(<<-RUBY)
      it do
        foo = double("Widget")
              ^^^^^^^^^^^^^^^^ Prefer using verifying doubles over normal doubles.
      end
    RUBY
  end

  context 'when configuration does not specify IgnoreSymbolicNames' do
    let(:cop_config) do
      {}
    end

    it 'find doubles whose name is a symbol' do
      expect_offense(<<-RUBY)
        it do
          foo = double(:widget)
                ^^^^^^^^^^^^^^^ Prefer using verifying doubles over normal doubles.
        end
      RUBY
    end

    it 'finds a `spy` instead of an `instance_spy`' do
      expect_offense(<<-RUBY)
        it do
          foo = spy("Widget")
                ^^^^^^^^^^^^^ Prefer using verifying doubles over normal doubles.
        end
      RUBY
    end
  end

  context 'when configured to ignore symbolic names' do
    let(:cop_config) do
      { 'IgnoreSymbolicNames' => true }
    end

    it 'ignores doubles whose name is a symbol' do
      expect_no_offenses(<<-RUBY)
        it do
          foo = double(:widget)
        end
      RUBY
    end

    it 'still flags doubles whose name is a string' do
      expect_offense(<<-RUBY)
        it do
          foo = double("widget")
                ^^^^^^^^^^^^^^^^ Prefer using verifying doubles over normal doubles.
        end
      RUBY
    end
  end

  context 'when configured not to ignore nameless doubles' do
    let(:cop_config) do
      { 'IgnoreNameless' => false }
    end

    it 'flags doubles that have no name specified' do
      expect_offense(<<-RUBY)
        it do
          foo = double
                ^^^^^^ Prefer using verifying doubles over normal doubles.
        end
      RUBY
    end
  end

  it 'ignores doubles that have no name specified' do
    expect_no_offenses(<<-RUBY)
      it do
        foo = double
      end
    RUBY
  end

  it 'ignores instance_doubles' do
    expect_no_offenses(<<-RUBY)
      it do
        foo = instance_double("Foo")
      end
    RUBY
  end
end
